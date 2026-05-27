package ni.devotion.floaty_chatheads.services

import android.app.Activity
import android.app.Application
import android.os.Bundle
import ni.devotion.floaty_chatheads.FloatyChatheadsPlugin

/**
 * Tracks how many activities are in the started state. When the count drops
 * to zero the app is considered backgrounded; when it rises from zero the
 * app is foregrounded.
 *
 * Mirrors the approach used by `ProcessLifecycleOwner` but avoids pulling
 * in the `lifecycle-process` dependency.
 */
internal class AutoLaunchLifecycleCallbacks(
    private val plugin: FloatyChatheadsPlugin,
) : Application.ActivityLifecycleCallbacks {

    private var startedCount = 0

    override fun onActivityStarted(activity: Activity) {
        val wasBackground = startedCount == 0
        startedCount++
        if (wasBackground) plugin.onAppForegrounded()
    }

    override fun onActivityStopped(activity: Activity) {
        startedCount--
        if (startedCount <= 0) {
            startedCount = 0
            plugin.onAppBackgrounded()
        }
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
    override fun onActivityResumed(activity: Activity) {}
    override fun onActivityPaused(activity: Activity) {}
    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
    override fun onActivityDestroyed(activity: Activity) {}
}
