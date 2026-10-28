package ni.devotion.floaty_chatheads.utils

import android.graphics.Bitmap
import android.graphics.Color
import android.util.Log

/** Which screen edge(s) the chathead snaps to. */
enum class SnapEdge { BOTH, LEFT, RIGHT, NONE }

/** Entrance animation style. */
enum class EntranceAnimation { NONE, POP, SLIDE_FROM_EDGE, FADE }

/** Where the expanded content panel is anchored relative to the bubble. */
enum class PanelAnchor { BELOW, ABOVE, AUTO }

/** Lock-screen visibility of the foreground-service notification. */
enum class NotificationVisibility { PUBLIC, SECRET, PRIVATE }

/**
 * Holds the overlay configuration that is shared across the plugin,
 * service, and native views.
 *
 * All fields are set by [FloatyChatheadsPlugin.showChatHead] and read
 * by native Android views. The service persists/restores them across
 * app-death via SharedPreferences.
 */
object OverlayConfig {
    @Volatile var floatingIcon: Bitmap? = null
    @Volatile var closeIcon: Bitmap? = null
    @Volatile var backgroundCloseIcon: Bitmap? = null

    /** When true, close icon came from widget rendering (bytes)
     *  and should be scaled to [CLOSE_SIZE] instead of the small 28dp default. */
    @Volatile var closeIconIsWidget: Boolean = false

    var notificationTitle: String = "Floaty Chathead"
    var notificationDescription: String? = null
    var notificationVisibility: NotificationVisibility = NotificationVisibility.PUBLIC
    @Volatile var notificationIcon: Bitmap? = null

    /** Width in dp: null = WRAP_CONTENT, >0 = explicit dp, <=0 = MATCH_PARENT. */
    var contentWidth: Int? = null
    /** Height in dp: null = WRAP_CONTENT, >0 = explicit dp, <=0 = MATCH_PARENT. */
    var contentHeight: Int? = null

    var snapEdge: SnapEdge = SnapEdge.BOTH
    /** Snap margin in dp. Negative = partially hidden off-screen. */
    var snapMargin: Float = -10f

    var persistPosition: Boolean = false

    var entranceAnimation: EntranceAnimation = EntranceAnimation.NONE

    /** Library URI of the entry point; null = the app's root library. */
    var entryPointLibrary: String? = null

    /** Where the expanded content panel opens relative to the bubble. */
    var panelAnchor: PanelAnchor = PanelAnchor.BELOW

    var badgeColor: Int = Color.RED
    var badgeTextColor: Int = Color.WHITE
    var bubbleBorderColor: Int? = null
    var bubbleBorderWidth: Float = 0f
    var bubbleShadowColor: Int = Color.argb(80, 0, 0, 0)
    var closeTintColor: Int? = null
    var overlayPalette: Map<String, Int>? = null

    /** Whether the chathead auto-shows when the app goes to background. */
    var autoLaunchOnBackground: Boolean = false
    /** Whether the overlay survives after the main app process is killed. */
    var persistOnAppClose: Boolean = false

    var debugMode: Boolean = false

    private const val TAG = "FloatyDebug"

    /** Logs a debug message only when [debugMode] is enabled. */
    fun logD(message: String) {
        if (debugMode) Log.d(TAG, message)
    }

    /** Logs a warning only when [debugMode] is enabled. */
    fun logW(message: String) {
        if (debugMode) Log.w(TAG, message)
    }

    /** Logs an error only when [debugMode] is enabled. */
    fun logE(message: String) {
        if (debugMode) Log.e(TAG, message)
    }
}
