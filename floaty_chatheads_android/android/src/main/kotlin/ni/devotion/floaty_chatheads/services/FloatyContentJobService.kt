package ni.devotion.floaty_chatheads.services

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.ViewGroup
import android.view.WindowManager
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngineCache
import ni.devotion.floaty_chatheads.FloatyChatheadsPlugin
import ni.devotion.floaty_chatheads.R
import ni.devotion.floaty_chatheads.floating_chathead.ChatHeads
import ni.devotion.floaty_chatheads.floating_chathead.WindowManagerHelper
import ni.devotion.floaty_chatheads.generated.FloatyOverlayFlutterApi
import ni.devotion.floaty_chatheads.generated.FloatyOverlayHostApi
import ni.devotion.floaty_chatheads.generated.OverlayFlagMessage
import ni.devotion.floaty_chatheads.generated.OverlayPositionMessage
import ni.devotion.floaty_chatheads.utils.Constants
import ni.devotion.floaty_chatheads.utils.Managment

class FloatyContentJobService : Service(), FloatyOverlayHostApi {

    companion object {
        var instance: FloatyContentJobService? = null
        private const val DEBUG_LOG_MAX_SIZE = 50
    }

    var windowManager: WindowManager? = null
    var chatHeads: ChatHeads? = null
    private var overlayFlutterApi: FloatyOverlayFlutterApi? = null

    // ── Debug: Pigeon message log ────────────────────────────────────
    private val debugMessageLog = ArrayDeque<Map<String, Any?>>(DEBUG_LOG_MAX_SIZE)

    private fun logPigeonCall(method: String, args: Map<String, Any?> = emptyMap()) {
        if (!Managment.debugMode) return
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

    override fun onCreate() {
        Log.d("FloatyDebug", "onCreate() called. instance=$instance")
        instance = this
        createNotificationChannel()
        showNotification()

        val engine = FlutterEngineCache.getInstance().get(Constants.OVERLAY_ENGINE_CACHE_TAG)
        Log.d("FloatyDebug", "onCreate() engine=$engine")
        if (engine != null) {
            FloatyOverlayHostApi.setUp(engine.dartExecutor, this)
            overlayFlutterApi = FloatyOverlayFlutterApi(engine.dartExecutor)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("FloatyDebug", "onStartCommand() called. chatHeads=$chatHeads, instance=$instance")
        if (chatHeads == null) {
            createWindow()
        } else {
            Log.d("FloatyDebug", "onStartCommand() chatHeads already exists — skipping createWindow()")
        }
        return START_STICKY
    }

    fun createWindow() {
        Log.d("FloatyDebug", "createWindow() called. instance=$instance, chatHeads=$chatHeads")
        // Ensure instance always points to the live service. When the
        // service is reused (stopSelf not yet completed), onCreate may
        // not be called again, leaving instance stale or null.
        instance = this
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        chatHeads = ChatHeads(this)
        chatHeads?.add(id = "default")

        // Apply configured content dimensions.
        //  • null  → keep default WRAP_CONTENT (small overlays)
        //  • > 0   → explicit dp → px
        //  • <= 0  → MATCH_PARENT (fullscreen overlays)
        val cw = Managment.contentWidth
        val ch = Managment.contentHeight
        if (cw != null || ch != null) {
            chatHeads?.content?.let { panel ->
                val lp = panel.layoutParams ?: return@let
                lp.width = when {
                    cw == null -> ViewGroup.LayoutParams.WRAP_CONTENT
                    cw <= 0    -> ViewGroup.LayoutParams.MATCH_PARENT
                    else       -> WindowManagerHelper.dpToPx(cw.toFloat())
                }
                lp.height = when {
                    ch == null -> ViewGroup.LayoutParams.WRAP_CONTENT
                    ch == -2   -> WindowManagerHelper.getScreenSize().heightPixels / 2
                    ch <= 0    -> ViewGroup.LayoutParams.MATCH_PARENT
                    else       -> WindowManagerHelper.dpToPx(ch.toFloat())
                }
                panel.layoutParams = lp
            }
        }

        val engine = FlutterEngineCache.getInstance().get(Constants.OVERLAY_ENGINE_CACHE_TAG)
        Log.d("FloatyDebug", "createWindow() engine=$engine, contentW=${Managment.contentWidth}, contentH=${Managment.contentHeight}, entranceAnim=${Managment.entranceAnimation}")
        if (engine != null) {
            // Re-register Pigeon APIs on the (possibly new) engine.
            // When the plugin tears down and restarts the overlay, the Android
            // service may be reused (onCreate not called again because stopSelf
            // hasn't fully completed).  In that case overlayFlutterApi still
            // points at the OLD destroyed engine.  Always re-bind here so the
            // Kotlin → Dart callbacks reach the correct isolate.
            FloatyOverlayHostApi.setUp(engine.dartExecutor, this)
            overlayFlutterApi = FloatyOverlayFlutterApi(engine.dartExecutor)

            chatHeads?.content?.attachEngine(engine)
            Log.d("FloatyDebug", "createWindow() engine attached. content.childCount=${chatHeads?.content?.childCount}, content.lp.w=${chatHeads?.content?.layoutParams?.width}, content.lp.h=${chatHeads?.content?.layoutParams?.height}")
        } else {
            Log.e("FloatyDebug", "createWindow() ENGINE IS NULL — overlay will not render!")
        }
    }

    fun addChatHead(id: String, icon: android.graphics.Bitmap?) {
        chatHeads?.add(id = id, icon = icon)
    }

    fun removeChatHead(id: String) {
        chatHeads?.remove(id)
    }

    fun closeWindow(stopService: Boolean) {
        Log.d("FloatyDebug", "closeWindow(stopService=$stopService) called. chatHeads=$chatHeads")
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

        try { overlayFlutterApi?.onChatHeadClosed(closedId) { } } catch (_: Exception) { }

        val engine = FlutterEngineCache.getInstance().get(Constants.OVERLAY_ENGINE_CACHE_TAG)
        if (engine != null) {
            FloatyOverlayHostApi.setUp(engine.dartExecutor, null)
        }

        if (stopService) {
            val notificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.cancel(Constants.NOTIFICATION_ID)
            stopSelf()
        }
    }

    // ── Lifecycle notification helpers ──────────────────────────────────

    fun notifyChatHeadTapped(id: String) {
        logPigeonCall("onChatHeadTapped", mapOf("id" to id))
        try { overlayFlutterApi?.onChatHeadTapped(id) { } } catch (_: Exception) { }
    }

    fun notifyChatHeadExpanded(id: String) {
        logPigeonCall("onChatHeadExpanded", mapOf("id" to id))
        try { overlayFlutterApi?.onChatHeadExpanded(id) { } } catch (_: Exception) { }
    }

    fun notifyChatHeadCollapsed(id: String) {
        logPigeonCall("onChatHeadCollapsed", mapOf("id" to id))
        try { overlayFlutterApi?.onChatHeadCollapsed(id) { } } catch (_: Exception) { }
    }

    fun notifyChatHeadDragStart(id: String, x: Double, y: Double) {
        logPigeonCall("onChatHeadDragStart", mapOf("id" to id, "x" to x, "y" to y))
        try { overlayFlutterApi?.onChatHeadDragStart(id, x, y) { } } catch (_: Exception) { }
    }

    fun notifyChatHeadDragEnd(id: String, x: Double, y: Double) {
        logPigeonCall("onChatHeadDragEnd", mapOf("id" to id, "x" to x, "y" to y))
        try { overlayFlutterApi?.onChatHeadDragEnd(id, x, y) { } } catch (_: Exception) { }
    }

    // ── FloatyOverlayHostApi implementation ─────────────────────────────

    override fun resizeContent(width: Long, height: Long) {
        chatHeads?.content?.let { panel ->
            val params = panel.layoutParams ?: return@let
            // Sentinel: width/height <= 0 means "fill the parent" (MATCH_PARENT).
            // This lets Android's layout system determine the exact size, avoiding
            // mismatches between displayMetrics and the actual window dimensions.
            params.width = if (width <= 0) ViewGroup.LayoutParams.MATCH_PARENT else WindowManagerHelper.dpToPx(width.toFloat())
            params.height = if (height <= 0) ViewGroup.LayoutParams.MATCH_PARENT else WindowManagerHelper.dpToPx(height.toFloat())
            panel.layoutParams = params
            // Force a layout pass so the FlutterView receives updated viewport metrics
            // even if the panel is still GONE (awaiting showContent()).
            panel.requestLayout()
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
            "debugMode" to Managment.debugMode,
            "toggled" to (chatHeads?.toggled ?: false),
            "captured" to (chatHeads?.captured ?: false),
            "chatHeadCount" to (chatHeads?.chatHeads?.size ?: 0),
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
        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val notificationIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent, pendingIntentFlags,
        )

        val builder = NotificationCompat.Builder(this, Constants.NOTIFICATION_CHANNEL_ID)
            .setContentTitle("${Managment.notificationTitle} is running")
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)

        if (Managment.notificationIcon != null) {
            builder.setLargeIcon(Managment.notificationIcon)
        }

        builder.setSmallIcon(R.drawable.ic_chathead)

        startForeground(Constants.NOTIFICATION_ID, builder.build())
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        Log.d("FloatyDebug", "onDestroy() called. instance=$instance")
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(Constants.NOTIFICATION_ID)
        instance = null
        super.onDestroy()
    }
}
