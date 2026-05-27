package ni.devotion.floaty_chatheads.services

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings

/**
 * Encapsulates the SYSTEM_ALERT_WINDOW permission flow: synchronous
 * check, async request via Settings activity, and the
 * [onActivityResult] callback that resolves the pending completion.
 *
 * On API < 23 the permission is granted at install time and all
 * methods return `true` synchronously.
 */
internal class OverlayPermissionHandler {

    companion object {
        const val PERMISSION_REQUEST_CODE = 2084
    }

    private var pendingCallback: ((Result<Boolean>) -> Unit)? = null

    /** Returns whether SYSTEM_ALERT_WINDOW is currently granted. */
    fun check(context: Context?): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        return Settings.canDrawOverlays(context)
    }

    /**
     * Launches the system overlay-permission settings screen and stores
     * [callback] for invocation when [onActivityResult] fires. Returns
     * immediately with `true` if permission is already granted, or
     * `false` if [activity] is null.
     */
    fun request(
        activity: Activity?,
        callback: (Result<Boolean>) -> Unit,
    ) {
        if (activity == null) {
            callback(Result.success(false))
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            callback(Result.success(true))
            return
        }
        if (Settings.canDrawOverlays(activity)) {
            callback(Result.success(true))
            return
        }
        pendingCallback = callback
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:${activity.packageName}"),
        )
        activity.startActivityForResult(intent, PERMISSION_REQUEST_CODE)
    }

    /**
     * Routes the activity result back to the pending request callback.
     * Returns true when the request code matches this handler.
     */
    fun handleActivityResult(requestCode: Int, context: Context?): Boolean {
        if (requestCode != PERMISSION_REQUEST_CODE) return false
        val granted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(context)
        } else {
            true
        }
        pendingCallback?.invoke(Result.success(granted))
        pendingCallback = null
        return true
    }
}
