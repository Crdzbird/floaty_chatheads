package ni.devotion.floaty_chatheads.services

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder

import android.view.ViewGroup
import android.view.WindowManager
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.BasicMessageChannel
import ni.devotion.floaty_chatheads.FloatyChatheadsPlugin
import ni.devotion.floaty_chatheads.R
import ni.devotion.floaty_chatheads.floating_chathead.ChatHeads
import ni.devotion.floaty_chatheads.floating_chathead.WindowManagerHelper
import ni.devotion.floaty_chatheads.generated.FloatyOverlayFlutterApi
import ni.devotion.floaty_chatheads.generated.FloatyOverlayHostApi
import ni.devotion.floaty_chatheads.generated.OverlayFlagMessage
import ni.devotion.floaty_chatheads.generated.OverlayPositionMessage
import ni.devotion.floaty_chatheads.utils.Constants
import ni.devotion.floaty_chatheads.utils.OverlayConfig

class FloatyContentJobService : Service(), FloatyOverlayHostApi {

    companion object {
        var instance: FloatyContentJobService? = null
        private const val DEBUG_LOG_MAX_SIZE = 50
    }

    var windowManager: WindowManager? = null
    var chatHeads: ChatHeads? = null
    private var overlayFlutterApi: FloatyOverlayFlutterApi? = null

    private lateinit var configPersistence: ConfigPersistence
    private lateinit var engineManager: OverlayEngineManager

    /// The overlay-side messenger owned by the service (delegated).
    val overlayMessenger: BasicMessageChannel<Any?>?
        get() = engineManager.overlayMessenger

    /// Whether the main app plugin is currently attached (delegated).
    val mainAppConnected: Boolean
        get() = engineManager.mainAppConnected

    // ── Debug: Pigeon message log ────────────────────────────────────
    private val debugMessageLog = ArrayDeque<Map<String, Any?>>(DEBUG_LOG_MAX_SIZE)

    private fun logPigeonCall(method: String, args: Map<String, Any?> = emptyMap()) {
        if (!OverlayConfig.debugMode) return
        val entry = mapOf(
            "timestamp" to System.currentTimeMillis(),
            "method" to method,
            "args" to args,
        )
        synchronized(debugMessageLog) {
            if (debugMessageLog.size >= DEBUG_LOG_MAX_SIZE) {
                debugMessageLog.removeFirst()
            }
            debugMessageLog.addLast(entry)
        }
    }

    // ── Public delegating methods (called by FloatyChatheadsPlugin) ──

    fun ensureOverlayEngine(entryPoint: String) {
        engineManager.ensureEngine(entryPoint)
    }

    fun destroyOverlayEngine() {
        engineManager.destroyEngine()
    }

    fun persistConfig(entryPoint: String) {
        configPersistence.persist(entryPoint)
    }

    fun clearPersistedConfig() {
        configPersistence.clear()
    }

    fun onMainAppConnected() {
        engineManager.onMainAppConnected()
    }

    /**
     * Sets up the relay so main→overlay messages work, but does NOT
     * send the `connected:true` signal to the overlay.  Used during
     * `onAttachedToEngine` reconnection to avoid triggering the overlay's
     * queue flush before the main Dart side has registered its handlers.
     */
    fun onMainAppRelay() {
        engineManager.onMainAppRelay()
    }

    fun onMainAppDisconnected() {
        engineManager.onMainAppDisconnected()
        // When persistOnAppClose is false, tear down the overlay and stop
        // the service as soon as the main app process disconnects.
        if (!OverlayConfig.persistOnAppClose) {
            closeWindow(true)
            FloatyChatheadsPlugin.isServiceRunning = false
        }
    }

    // ── Service lifecycle ───────────────────────────────────────────

    override fun onCreate() {
        OverlayConfig.logD("onCreate() called. instance=$instance")
        instance = this
        configPersistence = ConfigPersistence(this)
        engineManager = OverlayEngineManager(this)
        createNotificationChannel()
        showNotification()

        val engine = FlutterEngineCache.getInstance()
            .get(Constants.OVERLAY_ENGINE_CACHE_TAG)
        OverlayConfig.logD("onCreate() engine=$engine")

        if (engine != null) {
            // Engine already exists (normal startup via plugin).
            FloatyOverlayHostApi.setUp(engine.dartExecutor, this)
            overlayFlutterApi = FloatyOverlayFlutterApi(engine.dartExecutor)
            engineManager.setupMessenger(engine)
        } else if (FloatyChatheadsPlugin.activeInstance != null) {
            // Plugin is active — OverlayConfig fields are already populated
            // by the current showChatHead() call. Just read the entry
            // point from SharedPreferences; do NOT call restoreConfig()
            // because it would overwrite the in-memory OverlayConfig values
            // with stale or incomplete SharedPreferences data.
            val entryPoint = configPersistence.readEntryPoint()
            if (entryPoint != null) {
                OverlayConfig.logD(
                    "onCreate() plugin active, creating engine for '$entryPoint'",
                )
                engineManager.ensureEngine(entryPoint)
                val createdEngine = FlutterEngineCache.getInstance()
                    .get(Constants.OVERLAY_ENGINE_CACHE_TAG)
                if (createdEngine != null) {
                    FloatyOverlayHostApi.setUp(
                        createdEngine.dartExecutor, this,
                    )
                    overlayFlutterApi = FloatyOverlayFlutterApi(
                        createdEngine.dartExecutor,
                    )
                }
                // The main app plugin is active but showChatHead() couldn't
                // call onMainAppConnected() because this service hadn't
                // started yet. Set the flag now so overlay->main messages
                // are forwarded instead of silently dropped.
                engineManager.onMainAppConnected()
            }
        } else {
            // No engine and no plugin — either restarted after app
            // death via START_STICKY, or the service is starting async
            // from startForegroundService() while the plugin already
            // populated OverlayConfig.  Only call restoreConfig() when
            // OverlayConfig looks unpopulated (both dimensions null) to
            // avoid overwriting values the plugin just set.
            val configAlreadySet =
                OverlayConfig.contentWidth != null || OverlayConfig.contentHeight != null
            val entryPoint = if (configAlreadySet) {
                // OverlayConfig was populated by the plugin's
                // showChatHead() — just read the entry point.
                OverlayConfig.logD(
                    "onCreate() OverlayConfig already set " +
                        "(w=${OverlayConfig.contentWidth}, h=${OverlayConfig.contentHeight})" +
                        " — skipping restoreConfig()",
                )
                configPersistence.readEntryPoint()
            } else {
                configPersistence.restore()
            }
            if (entryPoint != null) {
                OverlayConfig.logD(
                    "onCreate() restoring engine for '$entryPoint'",
                )
                engineManager.ensureEngine(entryPoint)
                val restoredEngine = FlutterEngineCache.getInstance()
                    .get(Constants.OVERLAY_ENGINE_CACHE_TAG)
                if (restoredEngine != null) {
                    FloatyOverlayHostApi.setUp(
                        restoredEngine.dartExecutor, this,
                    )
                    overlayFlutterApi = FloatyOverlayFlutterApi(
                        restoredEngine.dartExecutor,
                    )
                }
            } else {
                OverlayConfig.logW(
                    "onCreate() no saved config — cannot restore overlay",
                )
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        OverlayConfig.logD(
            "onStartCommand() called. chatHeads=$chatHeads, instance=$instance, " +
                "pluginSetupInProgress=${FloatyChatheadsPlugin.activeInstance?.pluginSetupInProgress}",
        )
        // Re-post the foreground notification so Android doesn't kill the
        // service when startForegroundService() was used without onCreate().
        showNotification()

        // When the plugin is actively setting up the overlay (loading
        // icons in a coroutine), skip createWindow() here — the plugin
        // coroutine will call it after icons are loaded and OverlayConfig
        // is fully populated. Without this guard, onStartCommand could
        // create the window before icons are ready.
        val pluginBusy =
            FloatyChatheadsPlugin.activeInstance?.pluginSetupInProgress == true
        if (chatHeads == null && !pluginBusy) {
            createWindow()
        } else {
            OverlayConfig.logD(
                "onStartCommand() skipping createWindow(). " +
                    "chatHeads=${chatHeads != null}, pluginBusy=$pluginBusy",
            )
        }
        return if (OverlayConfig.persistOnAppClose) START_STICKY else START_NOT_STICKY
    }

    fun createWindow() {
        OverlayConfig.logD(
            "createWindow() called. instance=$instance, chatHeads=$chatHeads",
        )
        // Ensure instance always points to the live service. When the
        // service is reused (stopSelf not yet completed), onCreate may
        // not be called again, leaving instance stale or null.
        instance = this
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        chatHeads = ChatHeads(this)
        chatHeads?.add(id = "default")

        val engine = FlutterEngineCache.getInstance()
            .get(Constants.OVERLAY_ENGINE_CACHE_TAG)
        OverlayConfig.logD(
            "createWindow() engine=$engine, " +
                "contentW=${OverlayConfig.contentWidth}, " +
                "contentH=${OverlayConfig.contentHeight}, " +
                "entranceAnim=${OverlayConfig.entranceAnimation}",
        )
        if (engine != null) {
            // Re-register Pigeon APIs on the (possibly new) engine.
            FloatyOverlayHostApi.setUp(engine.dartExecutor, this)
            overlayFlutterApi = FloatyOverlayFlutterApi(engine.dartExecutor)

            chatHeads?.content?.attachEngine(engine)
        } else {
            OverlayConfig.logE(
                "createWindow() ENGINE IS NULL — overlay will not render!",
            )
        }

        // Apply configured content dimensions AFTER engine attachment
        // so the FlutterView's addView() doesn't reset the layout params.
        // Uses setContentSize() which stores the values and re-applies
        // them in showContent() when the panel transitions from GONE to
        // VISIBLE, guaranteeing the dimensions survive the layout cycle.
        //  * null  -> keep default (MATCH_PARENT from FrameLayout)
        //  * > 0   -> explicit dp -> px
        //  * <= 0  -> MATCH_PARENT (fullscreen overlays)
        val cw = OverlayConfig.contentWidth
        val ch = OverlayConfig.contentHeight
        if (cw != null || ch != null) {
            val w = when {
                cw == null -> ViewGroup.LayoutParams.WRAP_CONTENT
                cw <= 0    -> ViewGroup.LayoutParams.MATCH_PARENT
                else       -> WindowManagerHelper.dpToPx(cw.toFloat())
            }
            val h = when {
                ch == null -> ViewGroup.LayoutParams.WRAP_CONTENT
                ch == -2   -> WindowManagerHelper.getScreenSize().heightPixels / 2
                ch <= 0    -> ViewGroup.LayoutParams.MATCH_PARENT
                else       -> WindowManagerHelper.dpToPx(ch.toFloat())
            }
            chatHeads?.content?.setContentSize(w, h)
        }
        OverlayConfig.logD(
            "createWindow() done. " +
                "content.lp.w=${chatHeads?.content?.layoutParams?.width}, " +
                "content.lp.h=${chatHeads?.content?.layoutParams?.height}",
        )
    }

    fun addChatHead(id: String, icon: android.graphics.Bitmap?) {
        chatHeads?.add(id = id, icon = icon)
    }

    fun removeChatHead(id: String) {
        chatHeads?.remove(id)
    }

    fun closeWindow(stopService: Boolean) {
        OverlayConfig.logD(
            "closeWindow(stopService=$stopService) called. chatHeads=$chatHeads",
        )
        val closedId = chatHeads?.topChatHead?.id ?: "default"
        chatHeads?.content?.detachEngine()
        chatHeads?.let { ch ->
            ch.cleanup()
            windowManager?.let {
                ch.removeAllViews()
                it.removeView(ch)
            }
        }
        chatHeads = null
        windowManager = null

        try {
            overlayFlutterApi?.onChatHeadClosed(closedId) { }
        } catch (_: Exception) { }

        if (stopService) {
            // Notify the main app that the chathead was actually dismissed
            // (drag-to-close, overlay close button, or closeChatHead API).
            // Skipped when stopService=false — the caller is about to
            // recreate the window immediately (e.g. showChatHead
            // reconfiguration) and firing onClosed would incorrectly tell
            // the app the chathead was dismissed.
            try {
                FloatyChatheadsPlugin.activeInstance?.mainMessenger?.send(
                    mapOf(
                        Constants.SYSTEM_ENVELOPE to Constants.CLOSED_PREFIX,
                        Constants.CLOSED_PREFIX to mapOf("id" to closedId),
                    ),
                )
            } catch (_: Exception) { }

            configPersistence.clear()

            // Stop the foreground service and dismiss the notification
            // BEFORE engine destruction — destroyEngine() can throw when
            // called from within the overlay engine's own Pigeon handler,
            // and we must ensure the service stops regardless.
            @Suppress("DEPRECATION")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                stopForeground(STOP_FOREGROUND_REMOVE)
            } else {
                stopForeground(true)
            }
            val notificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.cancel(Constants.NOTIFICATION_ID)
            stopSelf()

            // Destroy engine after service teardown is guaranteed.
            try {
                engineManager.destroyEngine()
            } catch (_: Exception) { }
        } else {
            // Teardown for restart — just unbind Pigeon, keep engine logic
            // to the caller.
            val engine = FlutterEngineCache.getInstance()
                .get(Constants.OVERLAY_ENGINE_CACHE_TAG)
            if (engine != null) {
                FloatyOverlayHostApi.setUp(engine.dartExecutor, null)
            }
        }
    }

    // ── Lifecycle notification helpers ──────────────────────────────────

    private inline fun notifyOverlay(
        method: String,
        args: Map<String, Any?> = emptyMap(),
        call: FloatyOverlayFlutterApi.() -> Unit,
    ) {
        logPigeonCall(method, args)
        try {
            overlayFlutterApi?.call()
        } catch (_: Exception) { }
    }

    fun notifyChatHeadTapped(id: String) =
        notifyOverlay("onChatHeadTapped", mapOf("id" to id)) {
            onChatHeadTapped(id) { }
        }

    fun notifyChatHeadExpanded(id: String) =
        notifyOverlay("onChatHeadExpanded", mapOf("id" to id)) {
            onChatHeadExpanded(id) { }
        }

    fun notifyChatHeadCollapsed(id: String) =
        notifyOverlay("onChatHeadCollapsed", mapOf("id" to id)) {
            onChatHeadCollapsed(id) { }
        }

    fun notifyChatHeadDragStart(id: String, x: Double, y: Double) =
        notifyOverlay("onChatHeadDragStart", mapOf("id" to id, "x" to x, "y" to y)) {
            onChatHeadDragStart(id, x, y) { }
        }

    fun notifyChatHeadDragEnd(id: String, x: Double, y: Double) =
        notifyOverlay("onChatHeadDragEnd", mapOf("id" to id, "x" to x, "y" to y)) {
            onChatHeadDragEnd(id, x, y) { }
        }

    // ── FloatyOverlayHostApi implementation ─────────────────────────────

    override fun resizeContent(width: Long, height: Long) {
        chatHeads?.content?.let { panel ->
            val w = if (width <= 0) {
                ViewGroup.LayoutParams.MATCH_PARENT
            } else {
                WindowManagerHelper.dpToPx(width.toFloat())
            }
            val h = if (height <= 0) {
                ViewGroup.LayoutParams.MATCH_PARENT
            } else {
                WindowManagerHelper.dpToPx(height.toFloat())
            }
            panel.setContentSize(w, h)
        }
    }

    override fun updateFlag(flag: OverlayFlagMessage) {
        // Placeholder for future flag updates on the overlay window
    }

    override fun closeOverlay() {
        closeWindow(true)
        FloatyChatheadsPlugin.isServiceRunning = false
    }

    override fun getOverlayPosition(): OverlayPositionMessage {
        val topChatHead = chatHeads?.topChatHead
        return if (topChatHead != null) {
            OverlayPositionMessage(
                x = topChatHead.springX.currentValue,
                y = topChatHead.springY.currentValue,
            )
        } else {
            OverlayPositionMessage(x = 0.0, y = 0.0)
        }
    }

    override fun updateBadgeFromOverlay(count: Long) {
        chatHeads?.updateBadge(count.toInt())
    }

    override fun getDebugInfo(): Map<String?, Any?> {
        val top = chatHeads?.topChatHead
        val info = mutableMapOf<String?, Any?>(
            "debugMode" to OverlayConfig.debugMode,
            "toggled" to (chatHeads?.toggled ?: false),
            "captured" to (chatHeads?.captured ?: false),
            "chatHeadCount" to (chatHeads?.chatHeads?.size ?: 0),
            "mainAppConnected" to mainAppConnected,
        )
        if (top != null) {
            info["topSpringXVelocity"] = top.springX.velocity
            info["topSpringYVelocity"] = top.springY.velocity
            info["topSpringXEnd"] = top.springX.endValue
            info["topSpringYEnd"] = top.springY.endValue
            info["topX"] = top.springX.currentValue
            info["topY"] = top.springY.currentValue
        }
        info["contentVisibility"] = when (chatHeads?.content?.visibility) {
            android.view.View.VISIBLE -> "VISIBLE"
            android.view.View.GONE -> "GONE"
            android.view.View.INVISIBLE -> "INVISIBLE"
            else -> "UNKNOWN"
        }
        synchronized(debugMessageLog) {
            info["messageLog"] = debugMessageLog.toList()
        }
        return info
    }

    // ── Notification ────────────────────────────────────────────────────

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                Constants.NOTIFICATION_CHANNEL_ID,
                "Floaty Chathead Service",
                NotificationManager.IMPORTANCE_LOW,
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun showNotification() {
        val pendingIntentFlags = if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
        ) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val notificationIntent = packageManager
            .getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent, pendingIntentFlags,
        )

        val builder = NotificationCompat.Builder(
            this, Constants.NOTIFICATION_CHANNEL_ID,
        )
            .setContentTitle(
                if (OverlayConfig.notificationDescription != null)
                    OverlayConfig.notificationTitle
                else
                    "${OverlayConfig.notificationTitle} is running"
            )
            .apply {
                OverlayConfig.notificationDescription?.let { setContentText(it) }
            }
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)

        if (OverlayConfig.notificationIcon != null) {
            builder.setLargeIcon(OverlayConfig.notificationIcon)
        }

        builder.setSmallIcon(R.drawable.ic_chathead)

        startForeground(Constants.NOTIFICATION_ID, builder.build())
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        OverlayConfig.logD("onDestroy() called. instance=$instance")
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(Constants.NOTIFICATION_ID)
        instance = null
        super.onDestroy()
    }
}
