package ni.devotion.floaty_chatheads.services

import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import ni.devotion.floaty_chatheads.utils.Constants
import ni.devotion.floaty_chatheads.utils.EntranceAnimation
import ni.devotion.floaty_chatheads.utils.OverlayConfig
import ni.devotion.floaty_chatheads.utils.SnapEdge
import org.json.JSONObject

/**
 * Persists and restores [OverlayConfig] to/from SharedPreferences so
 * the overlay can survive app death (START_STICKY restart).
 */
internal class ConfigPersistence(private val context: Context) {

    private fun prefs(): SharedPreferences =
        context.getSharedPreferences(Constants.PREFS_NAME, Context.MODE_PRIVATE)

    /** Saves the current [OverlayConfig] fields and [entryPoint]. */
    fun persist(entryPoint: String) {
        prefs().edit().apply {
            putBoolean(Constants.PREF_HAS_SAVED_CONFIG, true)
            putString(Constants.PREF_ENTRY_POINT, entryPoint)
            OverlayConfig.contentWidth?.let { putInt(Constants.PREF_CONTENT_WIDTH, it) }
                ?: remove(Constants.PREF_CONTENT_WIDTH)
            OverlayConfig.contentHeight?.let { putInt(Constants.PREF_CONTENT_HEIGHT, it) }
                ?: remove(Constants.PREF_CONTENT_HEIGHT)
            putString(Constants.PREF_SNAP_EDGE, OverlayConfig.snapEdge.name)
            putFloat(Constants.PREF_SNAP_MARGIN, OverlayConfig.snapMargin)
            putBoolean(Constants.PREF_PERSIST_POSITION, OverlayConfig.persistPosition)
            putString(Constants.PREF_ENTRANCE_ANIMATION, OverlayConfig.entranceAnimation.name)
            putBoolean(Constants.PREF_DEBUG_MODE, OverlayConfig.debugMode)
            putBoolean(Constants.PREF_AUTO_LAUNCH_ON_BACKGROUND, OverlayConfig.autoLaunchOnBackground)
            putBoolean(Constants.PREF_PERSIST_ON_APP_CLOSE, OverlayConfig.persistOnAppClose)
            putString(Constants.PREF_NOTIFICATION_TITLE, OverlayConfig.notificationTitle)
            OverlayConfig.notificationDescription?.let {
                putString(Constants.PREF_NOTIFICATION_DESCRIPTION, it)
            } ?: remove(Constants.PREF_NOTIFICATION_DESCRIPTION)
            putInt(Constants.PREF_BADGE_COLOR, OverlayConfig.badgeColor)
            putInt(Constants.PREF_BADGE_TEXT_COLOR, OverlayConfig.badgeTextColor)
            OverlayConfig.bubbleBorderColor?.let {
                putInt(Constants.PREF_BUBBLE_BORDER_COLOR, it)
            } ?: remove(Constants.PREF_BUBBLE_BORDER_COLOR)
            putFloat(Constants.PREF_BUBBLE_BORDER_WIDTH, OverlayConfig.bubbleBorderWidth)
            putInt(Constants.PREF_BUBBLE_SHADOW_COLOR, OverlayConfig.bubbleShadowColor)
            OverlayConfig.closeTintColor?.let {
                putInt(Constants.PREF_CLOSE_TINT_COLOR, it)
            } ?: remove(Constants.PREF_CLOSE_TINT_COLOR)
            OverlayConfig.overlayPalette?.let { palette ->
                putString(
                    Constants.PREF_OVERLAY_PALETTE,
                    JSONObject(palette.mapValues { it.value }).toString(),
                )
            } ?: remove(Constants.PREF_OVERLAY_PALETTE)
            apply()
        }
    }

    /**
     * Restores [OverlayConfig] from SharedPreferences.
     * Returns the saved entry point, or null if no config was persisted.
     */
    fun restore(): String? {
        val prefs = prefs()
        if (!prefs.getBoolean(Constants.PREF_HAS_SAVED_CONFIG, false)) return null

        val entryPoint = prefs.getString(Constants.PREF_ENTRY_POINT, null) ?: return null

        OverlayConfig.contentWidth = if (prefs.contains(Constants.PREF_CONTENT_WIDTH)) {
            prefs.getInt(Constants.PREF_CONTENT_WIDTH, 0)
        } else null

        OverlayConfig.contentHeight = if (prefs.contains(Constants.PREF_CONTENT_HEIGHT)) {
            prefs.getInt(Constants.PREF_CONTENT_HEIGHT, 0)
        } else null

        OverlayConfig.snapEdge = try {
            SnapEdge.valueOf(prefs.getString(Constants.PREF_SNAP_EDGE, "BOTH")!!)
        } catch (_: Exception) { SnapEdge.BOTH }

        OverlayConfig.snapMargin = prefs.getFloat(Constants.PREF_SNAP_MARGIN, -10f)
        OverlayConfig.persistPosition = prefs.getBoolean(Constants.PREF_PERSIST_POSITION, false)

        OverlayConfig.entranceAnimation = try {
            EntranceAnimation.valueOf(
                prefs.getString(Constants.PREF_ENTRANCE_ANIMATION, "NONE")!!,
            )
        } catch (_: Exception) { EntranceAnimation.NONE }

        OverlayConfig.debugMode = prefs.getBoolean(Constants.PREF_DEBUG_MODE, false)
        OverlayConfig.autoLaunchOnBackground = prefs.getBoolean(Constants.PREF_AUTO_LAUNCH_ON_BACKGROUND, false)
        OverlayConfig.persistOnAppClose = prefs.getBoolean(Constants.PREF_PERSIST_ON_APP_CLOSE, false)
        OverlayConfig.notificationTitle = prefs.getString(
            Constants.PREF_NOTIFICATION_TITLE, "Floaty Chathead",
        )!!
        OverlayConfig.notificationDescription = prefs.getString(
            Constants.PREF_NOTIFICATION_DESCRIPTION, null,
        )
        OverlayConfig.badgeColor = prefs.getInt(Constants.PREF_BADGE_COLOR, Color.RED)
        OverlayConfig.badgeTextColor = prefs.getInt(Constants.PREF_BADGE_TEXT_COLOR, Color.WHITE)
        OverlayConfig.bubbleBorderColor = if (prefs.contains(Constants.PREF_BUBBLE_BORDER_COLOR)) {
            prefs.getInt(Constants.PREF_BUBBLE_BORDER_COLOR, 0)
        } else null
        OverlayConfig.bubbleBorderWidth = prefs.getFloat(Constants.PREF_BUBBLE_BORDER_WIDTH, 0f)
        OverlayConfig.bubbleShadowColor = prefs.getInt(
            Constants.PREF_BUBBLE_SHADOW_COLOR, Color.argb(80, 0, 0, 0),
        )
        OverlayConfig.closeTintColor = if (prefs.contains(Constants.PREF_CLOSE_TINT_COLOR)) {
            prefs.getInt(Constants.PREF_CLOSE_TINT_COLOR, 0)
        } else null

        prefs.getString(Constants.PREF_OVERLAY_PALETTE, null)?.let { json ->
            try {
                val obj = JSONObject(json)
                val palette = mutableMapOf<String, Int>()
                for (key in obj.keys()) {
                    palette[key] = obj.getInt(key)
                }
                OverlayConfig.overlayPalette = palette
            } catch (_: Exception) {
                OverlayConfig.overlayPalette = null
            }
        }

        return entryPoint
    }

    /** Clears all persisted config. */
    fun clear() {
        prefs().edit().clear().apply()
    }

    /** Reads just the entry point without restoring the full config. */
    fun readEntryPoint(): String? =
        prefs().getString(Constants.PREF_ENTRY_POINT, null)
}
