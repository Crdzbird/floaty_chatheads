package ni.devotion.floaty_chatheads.floating_chathead

import android.content.Context
import android.content.SharedPreferences
import ni.devotion.floaty_chatheads.utils.OverlayConfig

/**
 * Persists and restores the chathead's last (x, y, onRight) so the
 * bubble can come back to where the user last left it across app
 * sessions.
 *
 * Only writes when [OverlayConfig.persistPosition] is `true`; same for
 * reads. Stored in a dedicated SharedPreferences file so the keys
 * cannot collide with consumer-app preferences.
 */
internal class ChatHeadPositionStore(context: Context) {

    private companion object {
        const val PREFS_NAME = "floaty_chatheads_position"
        const val KEY_X = "last_x"
        const val KEY_Y = "last_y"
        const val KEY_ON_RIGHT = "on_right"
    }

    /** Saved position read back via [load]. */
    data class SavedPosition(val x: Float, val y: Float, val onRight: Boolean)

    private val prefs: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    /** Persists [x], [y], and [onRight]. No-op when persistence is off. */
    fun save(x: Double, y: Double, onRight: Boolean) {
        if (!OverlayConfig.persistPosition) return
        prefs.edit()
            .putFloat(KEY_X, x.toFloat())
            .putFloat(KEY_Y, y.toFloat())
            .putBoolean(KEY_ON_RIGHT, onRight)
            .apply()
    }

    /**
     * Returns the previously saved position, or `null` when persistence
     * is off or nothing has been saved yet.
     */
    fun load(): SavedPosition? {
        if (!OverlayConfig.persistPosition) return null
        if (!prefs.contains(KEY_X)) return null
        return SavedPosition(
            x = prefs.getFloat(KEY_X, 0f),
            y = prefs.getFloat(KEY_Y, 0f),
            onRight = prefs.getBoolean(KEY_ON_RIGHT, false),
        )
    }
}
