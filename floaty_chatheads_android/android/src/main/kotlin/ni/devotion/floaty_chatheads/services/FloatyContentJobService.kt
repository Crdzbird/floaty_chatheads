package ni.devotion.floaty_chatheads.services

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.os.Build
import android.os.IBinder

import android.view.ViewGroup
import android.view.WindowManager
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.FlutterInjector
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.JSONMessageCodec
import ni.devotion.floaty_chatheads.FloatyChatheadsPlugin
import ni.devotion.floaty_chatheads.R
import ni.devotion.floaty_chatheads.floating_chathead.ChatHeads
import ni.devotion.floaty_chatheads.floating_chathead.WindowManagerHelper
import ni.devotion.floaty_chatheads.generated.FloatyOverlayFlutterApi
import ni.devotion.floaty_chatheads.generated.FloatyOverlayHostApi
import ni.devotion.floaty_chatheads.generated.OverlayFlagMessage
import ni.devotion.floaty_chatheads.generated.OverlayPositionMessage
import ni.devotion.floaty_chatheads.utils.Constants
import ni.devotion.floaty_chatheads.utils.EntranceAnimation
import ni.devotion.floaty_chatheads.utils.Managment
import ni.devotion.floaty_chatheads.utils.SnapEdge
import org.json.JSONObject

class FloatyContentJobService : Service(), FloatyOverlayHostApi {

    companion object {
        var instance: FloatyContentJobService? = null
        private const val DEBUG_LOG_MAX_SIZE = 50
    }

    var windowManager: WindowManager? = null
    var chatHeads: ChatHeads? = null
    private var overlayFlutterApi: FloatyOverlayFlutterApi? = null

    /// The overlay-side messenger owned by the service.
    var overlayMessenger: BasicMessageChannel<Any?>? = null
        private set

    /// Whether the main app plugin is currently attached.
    var mainAppConnected: Boolean = false
        private set

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

    private fun getPrefs(): SharedPreferences {
        return getSharedPreferences(Constants.PREFS_NAME, Context.MODE_PRIVATE)
    }

    // ── Engine lifecycle (owned by the service) ─────────────────────

    /**
     * Creates a new overlay Flutter engine, caches it, and sets up the
     * overlay-side messenger. This is the single source of truth for
     * engine creation — the plugin delegates to the service.
     */
    fun ensureOverlayEngine(entryPoint: String) {
        // If the engine already exists, skip recreation.
        val existing = FlutterEngineCache.getInstance()
            .get(Constants.OVERLAY_ENGINE_CACHE_TAG)
        if (existing != null) {
            Managment.logD("ensureOverlayEngine: engine already cached")
            setupOverlayMessenger(existing)
            return
        }

        Managment.logD("ensureOverlayEngine: creating engine for '$entryPoint'")
        val engineGroup = FlutterEngineGroup(this)
        val dartEntrypoint = DartExecutor.DartEntrypoint(
            FlutterInjector.instance().flutterLoader().findAppBundlePath(),
            entryPoint,
        )
        val engine = engineGroup.createAndRunEngine(this, dartEntrypoint)
        FlutterEngineCache.getInstance()
            .put(Constants.OVERLAY_ENGINE_CACHE_TAG, engine)

        setupOverlayMessenger(engine)

        // Send theme palette to overlay isolate if configured.
        Managment.overlayPalette?.let { palette ->
            overlayMessenger?.send(mapOf("_floaty_theme" to palette))
        }
    }

    /**
     * Sets up the overlay-side BasicMessageChannel on the given engine.
     * Messages from the overlay are forwarded to the main app's plugin
     * when connected; otherwise replies are null.
     */
    private fun setupOverlayMessenger(engine: FlutterEngine) {
        overlayMessenger = BasicMessageChannel(
            engine.dartExecutor,
            Constants.MESSENGER_TAG,
            JSONMessageCodec.INSTANCE,
        )
        overlayMessenger?.setMessageHandler { message, reply ->
            val plugin = FloatyChatheadsPlugin.activeInstance
            if (plugin != null && mainAppConnected) {
                plugin.mainMessenger?.send(message, reply)
            } else {
                reply.reply(null)
            }
        }
    }

    /**
     * Destroys the overlay engine and cleans up the messenger.
     */
    fun destroyOverlayEngine() {
        overlayMessenger?.setMessageHandler(null)
        overlayMessenger = null

        val engine = FlutterEngineCache.getInstance()
            .get(Constants.OVERLAY_ENGINE_CACHE_TAG)
        if (engine != null) {
            FlutterEngineCache.getInstance()
                .remove(Constants.OVERLAY_ENGINE_CACHE_TAG)
            engine.destroy()
        }
    }

    // ── Config persistence ──────────────────────────────────────────

    /**
     * Saves overlay configuration to SharedPreferences so the service
     * can restore it after app death.
     */
    fun persistConfig(entryPoint: String) {
        getPrefs().edit().apply {
            putBoolean(Constants.PREF_HAS_SAVED_CONFIG, true)
            putString(Constants.PREF_ENTRY_POINT, entryPoint)
            Managment.contentWidth?.let { putInt(Constants.PREF_CONTENT_WIDTH, it) }
                ?: remove(Constants.PREF_CONTENT_WIDTH)
            Managment.contentHeight?.let { putInt(Constants.PREF_CONTENT_HEIGHT, it) }
                ?: remove(Constants.PREF_CONTENT_HEIGHT)
            putString(Constants.PREF_SNAP_EDGE, Managment.snapEdge.name)
            putFloat(Constants.PREF_SNAP_MARGIN, Managment.snapMargin)
            putBoolean(Constants.PREF_PERSIST_POSITION, Managment.persistPosition)
            putString(
                Constants.PREF_ENTRANCE_ANIMATION,
                Managment.entranceAnimation.name,
            )
            putBoolean(Constants.PREF_DEBUG_MODE, Managment.debugMode)
            putString(Constants.PREF_NOTIFICATION_TITLE, Managment.notificationTitle)
            putInt(Constants.PREF_BADGE_COLOR, Managment.badgeColor)
            putInt(Constants.PREF_BADGE_TEXT_COLOR, Managment.badgeTextColor)
            Managment.bubbleBorderColor?.let {
                putInt(Constants.PREF_BUBBLE_BORDER_COLOR, it)
            } ?: remove(Constants.PREF_BUBBLE_BORDER_COLOR)
            putFloat(Constants.PREF_BUBBLE_BORDER_WIDTH, Managment.bubbleBorderWidth)
            putInt(Constants.PREF_BUBBLE_SHADOW_COLOR, Managment.bubbleShadowColor)
            Managment.closeTintColor?.let {
                putInt(Constants.PREF_CLOSE_TINT_COLOR, it)
            } ?: remove(Constants.PREF_CLOSE_TINT_COLOR)
            // Serialize overlay palette as JSON string.
            Managment.overlayPalette?.let { palette ->
                putString(
                    Constants.PREF_OVERLAY_PALETTE,
                    JSONObject(palette.mapValues { it.value }).toString(),
                )
            } ?: remove(Constants.PREF_OVERLAY_PALETTE)
            apply()
        }
    }

    /**
     * Restores overlay configuration from SharedPreferences into
     * Managment fields. Returns the saved entry point, or null if
     * no config was persisted.
     */
    private fun restoreConfig(): String? {
        val prefs = getPrefs()
        if (!prefs.getBoolean(Constants.PREF_HAS_SAVED_CONFIG, false)) return null

        val entryPoint = prefs.getString(Constants.PREF_ENTRY_POINT, null)
            ?: return null

        Managment.contentWidth = if (prefs.contains(Constants.PREF_CONTENT_WIDTH)) {
            prefs.getInt(Constants.PREF_CONTENT_WIDTH, 0)
        } else null

        Managment.contentHeight = if (prefs.contains(Constants.PREF_CONTENT_HEIGHT)) {
            prefs.getInt(Constants.PREF_CONTENT_HEIGHT, 0)
        } else null

        Managment.snapEdge = try {
            SnapEdge.valueOf(prefs.getString(Constants.PREF_SNAP_EDGE, "BOTH")!!)
        } catch (_: Exception) { SnapEdge.BOTH }

        Managment.snapMargin = prefs.getFloat(Constants.PREF_SNAP_MARGIN, -10f)
        Managment.persistPosition = prefs.getBoolean(
            Constants.PREF_PERSIST_POSITION, false,
        )

        Managment.entranceAnimation = try {
            EntranceAnimation.valueOf(
                prefs.getString(Constants.PREF_ENTRANCE_ANIMATION, "NONE")!!,
            )
        } catch (_: Exception) { EntranceAnimation.NONE }

        Managment.debugMode = prefs.getBoolean(Constants.PREF_DEBUG_MODE, false)
        Managment.notificationTitle = prefs.getString(
            Constants.PREF_NOTIFICATION_TITLE, "Floaty Chathead",
        )!!
        Managment.badgeColor = prefs.getInt(
            Constants.PREF_BADGE_COLOR, Color.RED,
        )
        Managment.badgeTextColor = prefs.getInt(
            Constants.PREF_BADGE_TEXT_COLOR, Color.WHITE,
        )
        Managment.bubbleBorderColor = if (
            prefs.contains(Constants.PREF_BUBBLE_BORDER_COLOR)
        ) {
            prefs.getInt(Constants.PREF_BUBBLE_BORDER_COLOR, 0)
        } else null

        Managment.bubbleBorderWidth = prefs.getFloat(
            Constants.PREF_BUBBLE_BORDER_WIDTH, 0f,
        )
        Managment.bubbleShadowColor = prefs.getInt(
            Constants.PREF_BUBBLE_SHADOW_COLOR,
            Color.argb(80, 0, 0, 0),
        )
        Managment.closeTintColor = if (
            prefs.contains(Constants.PREF_CLOSE_TINT_COLOR)
        ) {
            prefs.getInt(Constants.PREF_CLOSE_TINT_COLOR, 0)
        } else null

        // Restore overlay palette from JSON string.
        prefs.getString(Constants.PREF_OVERLAY_PALETTE, null)?.let { json ->
            try {
                val obj = JSONObject(json)
                val palette = mutableMapOf<String, Int>()
                for (key in obj.keys()) {
                    palette[key] = obj.getInt(key)
                }
                Managment.overlayPalette = palette
            } catch (_: Exception) {
                Managment.overlayPalette = null
            }
        }

        return entryPoint
    }

    /**
     * Clears persisted config when the overlay is explicitly closed.
     */
    fun clearPersistedConfig() {
        getPrefs().edit().clear().apply()
    }

    // ── Main app connection management ──────────────────────────────

    /**
     * Called by the plugin when it attaches. Re-establishes the relay
     * and notifies the overlay Dart side.
     */
    fun onMainAppConnected() {
        mainAppConnected = true
        // Re-setup the overlay messenger relay to forward to the new
        // plugin instance.
        val engine = FlutterEngineCache.getInstance()
            .get(Constants.OVERLAY_ENGINE_CACHE_TAG)
        if (engine != null) {
            setupOverlayMessenger(engine)
        }
        // Notify overlay Dart side.
        overlayMessenger?.send(
            mapOf(Constants.CONNECTION_PREFIX to mapOf("connected" to true)),
        )
    }

    /**
     * Called by the plugin when it detaches. Notifies the overlay
     * Dart side but keeps the engine alive.
     */
    fun onMainAppDisconnected() {
        mainAppConnected = false
        // Notify overlay Dart side.
        overlayMessenger?.send(
            mapOf(Constants.CONNECTION_PREFIX to mapOf("connected" to false)),
        )
        // Update the overlay messenger to stop forwarding to main app.
        val engine = FlutterEngineCache.getInstance()
            .get(Constants.OVERLAY_ENGINE_CACHE_TAG)
        if (engine != null) {
            overlayMessenger?.setMessageHandler { _, reply ->
                reply.reply(null)
            }
        }
    }

    // ── Service lifecycle ───────────────────────────────────────────

    override fun onCreate() {
        Managment.logD("onCreate() called. instance=$instance")
        instance = this
        createNotificationChannel()
        showNotification()

        val engine = FlutterEngineCache.getInstance()
            .get(Constants.OVERLAY_ENGINE_CACHE_TAG)
        Managment.logD("onCreate() engine=$engine")

        if (engine != null) {
            // Engine already exists (normal startup via plugin).
            FloatyOverlayHostApi.setUp(engine.dartExecutor, this)
            overlayFlutterApi = FloatyOverlayFlutterApi(engine.dartExecutor)
            setupOverlayMessenger(engine)
        } else if (FloatyChatheadsPlugin.activeInstance != null) {
            // Plugin is active — Managment fields are already populated
            // by the current showChatHead() call. Just read the entry
            // point from SharedPreferences; do NOT call restoreConfig()
            // because it would overwrite the in-memory Managment values
            // with stale or incomplete SharedPreferences data.
            val entryPoint = getPrefs().getString(
                Constants.PREF_ENTRY_POINT, null,
            )
            if (entryPoint != null) {
                Managment.logD(
                    "onCreate() plugin active, creating engine for '$entryPoint'",
                )
                ensureOverlayEngine(entryPoint)
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
                // started yet. Set the flag now so overlay→main messages
                // are forwarded instead of silently dropped.
                onMainAppConnected()
            }
        } else {
            // No engine and no plugin — either restarted after app
            // death via START_STICKY, or the service is starting async
            // from startForegroundService() while the plugin already
            // populated Managment.  Only call restoreConfig() when
            // Managment looks unpopulated (both dimensions null) to
            // avoid overwriting values the plugin just set.
            val managmentAlreadySet =
                Managment.contentWidth != null || Managment.contentHeight != null
            val entryPoint = if (managmentAlreadySet) {
                // Managment was populated by the plugin's
                // showChatHead() — just read the entry point.
                Managment.logD(
                    "onCreate() Managment already set " +
                        "(w=${Managment.contentWidth}, h=${Managment.contentHeight})" +
                        " — skipping restoreConfig()",
                )
                getPrefs().getString(Constants.PREF_ENTRY_POINT, null)
            } else {
                restoreConfig()
            }
            if (entryPoint != null) {
                Managment.logD(
                    "onCreate() restoring engine for '$entryPoint'",
                )
                ensureOverlayEngine(entryPoint)
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
                Managment.logW(
                    "onCreate() no saved config — cannot restore overlay",
                )
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Managment.logD(
            "onStartCommand() called. chatHeads=$chatHeads, instance=$instance",
        )
        // Re-post the foreground notification so Android doesn't kill the
        // service when startForegroundService() was used without onCreate().
        showNotification()
        if (chatHeads == null) {
            createWindow()
        } else {
            Managment.logD(
                "onStartCommand() chatHeads already exists — skipping createWindow()",
            )
        }
        return START_STICKY
    }

    fun createWindow() {
        Managment.logD(
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
        Managment.logD(
            "createWindow() engine=$engine, " +
                "contentW=${Managment.contentWidth}, " +
                "contentH=${Managment.contentHeight}, " +
                "entranceAnim=${Managment.entranceAnimation}",
        )
        if (engine != null) {
            // Re-register Pigeon APIs on the (possibly new) engine.
            FloatyOverlayHostApi.setUp(engine.dartExecutor, this)
            overlayFlutterApi = FloatyOverlayFlutterApi(engine.dartExecutor)

            chatHeads?.content?.attachEngine(engine)
        } else {
            Managment.logE(
                "createWindow() ENGINE IS NULL — overlay will not render!",
            )
        }

        // Apply configured content dimensions AFTER engine attachment
        // so the FlutterView's addView() doesn't reset the layout params.
        // Uses setContentSize() which stores the values and re-applies
        // them in showContent() when the panel transitions from GONE to
        // VISIBLE, guaranteeing the dimensions survive the layout cycle.
        //  • null  → keep default (MATCH_PARENT from FrameLayout)
        //  • > 0   → explicit dp → px
        //  • <= 0  → MATCH_PARENT (fullscreen overlays)
        val cw = Managment.contentWidth
        val ch = Managment.contentHeight
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
        Managment.logD(
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
        Managment.logD(
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
            // Explicit close — destroy engine and clear persisted config.
            destroyOverlayEngine()
            clearPersistedConfig()

            val notificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.cancel(Constants.NOTIFICATION_ID)
            stopSelf()
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

    fun notifyChatHeadTapped(id: String) {
        logPigeonCall("onChatHeadTapped", mapOf("id" to id))
        try {
            overlayFlutterApi?.onChatHeadTapped(id) { }
        } catch (_: Exception) { }
    }

    fun notifyChatHeadExpanded(id: String) {
        logPigeonCall("onChatHeadExpanded", mapOf("id" to id))
        try {
            overlayFlutterApi?.onChatHeadExpanded(id) { }
        } catch (_: Exception) { }
    }

    fun notifyChatHeadCollapsed(id: String) {
        logPigeonCall("onChatHeadCollapsed", mapOf("id" to id))
        try {
            overlayFlutterApi?.onChatHeadCollapsed(id) { }
        } catch (_: Exception) { }
    }

    fun notifyChatHeadDragStart(id: String, x: Double, y: Double) {
        logPigeonCall(
            "onChatHeadDragStart",
            mapOf("id" to id, "x" to x, "y" to y),
        )
        try {
            overlayFlutterApi?.onChatHeadDragStart(id, x, y) { }
        } catch (_: Exception) { }
    }

    fun notifyChatHeadDragEnd(id: String, x: Double, y: Double) {
        logPigeonCall(
            "onChatHeadDragEnd",
            mapOf("id" to id, "x" to x, "y" to y),
        )
        try {
            overlayFlutterApi?.onChatHeadDragEnd(id, x, y) { }
        } catch (_: Exception) { }
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
            "debugMode" to Managment.debugMode,
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
        Managment.logD("onDestroy() called. instance=$instance")
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(Constants.NOTIFICATION_ID)
        instance = null
        super.onDestroy()
    }
}
