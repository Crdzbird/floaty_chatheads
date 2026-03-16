package ni.devotion.floaty_chatheads.utils

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Color
import android.util.Log

/** Which screen edge(s) the chathead snaps to. */
enum class SnapEdge { BOTH, LEFT, RIGHT, NONE }

/** Entrance animation style. */
enum class EntranceAnimation { NONE, POP, SLIDE_FROM_EDGE, FADE }

object Managment {
    var floatingIcon: Bitmap? = null
    var closeIcon: Bitmap? = null
    var backgroundCloseIcon: Bitmap? = null
    var notificationTitle: String = "Floaty Chathead"
    var notificationIcon: Bitmap? = null
    var globalContext: Context? = null
    var activity: Activity? = null
    /** Content panel width in dp: null = WRAP_CONTENT, >0 = explicit dp, <=0 = MATCH_PARENT. */
    var contentWidth: Int? = null
    /** Content panel height in dp: null = WRAP_CONTENT, >0 = explicit dp, <=0 = MATCH_PARENT. */
    var contentHeight: Int? = null

    // ── Snap behavior ───────────────────────────────────────────────
    var snapEdge: SnapEdge = SnapEdge.BOTH
    /** Snap margin in dp. Negative = partially hidden off-screen. */
    var snapMargin: Float = -10f  // default matches CHAT_HEAD_OUT_OF_SCREEN_X

    // ── Persistent position ─────────────────────────────────────────
    var persistPosition: Boolean = false

    // ── Entrance animation ──────────────────────────────────────────
    var entranceAnimation: EntranceAnimation = EntranceAnimation.NONE

    // ── Theming ─────────────────────────────────────────────────────
    var badgeColor: Int = Color.RED
    var badgeTextColor: Int = Color.WHITE
    var bubbleBorderColor: Int? = null
    var bubbleBorderWidth: Float = 0f
    var bubbleShadowColor: Int = Color.argb(80, 0, 0, 0)
    var closeTintColor: Int? = null
    var overlayPalette: Map<String, Int>? = null

    // ── Debug ───────────────────────────────────────────────────────
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
