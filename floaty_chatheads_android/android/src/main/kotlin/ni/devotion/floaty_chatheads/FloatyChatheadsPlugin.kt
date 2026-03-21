package ni.devotion.floaty_chatheads

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.JSONMessageCodec
import io.flutter.plugin.common.PluginRegistry
import ni.devotion.floaty_chatheads.generated.AddChatHeadConfig
import ni.devotion.floaty_chatheads.generated.ChatHeadConfig
import ni.devotion.floaty_chatheads.generated.FloatyHostApi
import ni.devotion.floaty_chatheads.generated.IconSourceMessage
import ni.devotion.floaty_chatheads.generated.IconSourceTypeMessage
import ni.devotion.floaty_chatheads.services.ConfigPersistence
import ni.devotion.floaty_chatheads.services.FloatyContentJobService
import ni.devotion.floaty_chatheads.utils.Constants
import ni.devotion.floaty_chatheads.utils.EntranceAnimation
import ni.devotion.floaty_chatheads.utils.OverlayConfig
import ni.devotion.floaty_chatheads.utils.SnapEdge
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL

class FloatyChatheadsPlugin :
    FlutterPlugin,
    ActivityAware,
    FloatyHostApi,
    PluginRegistry.ActivityResultListener {

    companion object {
        private const val PERMISSION_REQUEST_CODE = 2084
        /** Timeout (ms) for each icon load (network connect + read + decode). */
        private const val ICON_LOAD_TIMEOUT_MS = 4_000L
        private const val NETWORK_CONNECT_TIMEOUT_MS = 3_000
        private const val NETWORK_READ_TIMEOUT_MS = 3_000
        var isServiceRunning = false

        /**
         * The currently attached plugin instance. Used by the service
         * to forward overlay messages to the main Dart side.
         */
        var activeInstance: FloatyChatheadsPlugin? = null
            private set
    }

    private var activity: Activity? = null
    private var context: Context? = null
    var mainMessenger: BasicMessageChannel<Any?>? = null
        private set
    private var pendingPermissionResult: ((Result<Boolean>) -> Unit)? = null
    private var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null

    /**
     * True when `onAttachedToEngine` detected an existing overlay and set
     * up the relay, but deferred the `connected:true` signal.  Cleared
     * when `isChatHeadActive()` triggers the actual signal.
     */
    private var pendingConnectionSignal = false

    /**
     * True when this plugin instance is attached to the **main** engine.
     * When [FlutterEngineGroup.createAndRunEngine] creates the overlay
     * engine it auto-registers all plugins, including this one.  The
     * overlay instance must NOT overwrite [activeInstance] or
     * [mainMessenger] — doing so would cause overlay→main messages to
     * loop back to the overlay instead of reaching the main Dart side.
     */
    private var isMainEnginePlugin = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Guard: FlutterEngineGroup auto-registers plugins on the
        // overlay engine.  Only the first attachment (the main engine)
        // should set up the messenger relay.
        if (activeInstance != null) {
            // This is the overlay engine — skip setup entirely.
            return
        }

        isMainEnginePlugin = true
        flutterPluginBinding = binding
        context = binding.applicationContext
        activeInstance = this
        FloatyHostApi.setUp(binding.binaryMessenger, this)

        mainMessenger = BasicMessageChannel(
            binding.binaryMessenger,
            Constants.MESSENGER_TAG,
            JSONMessageCodec.INSTANCE,
        )
        // Main → Overlay relay: forward messages from the main Dart
        // to the overlay Dart via the service's overlay messenger.
        mainMessenger?.setMessageHandler { message, reply ->
            val service = FloatyContentJobService.instance
            if (service?.overlayMessenger != null) {
                service.overlayMessenger?.send(message, reply)
            } else {
                reply.reply(null)
            }
        }

        // If the service is already running (app restart / hot-restart),
        // note that we need to reconnect but DON'T send `connected:true`
        // to the overlay yet.  The overlay would flush its action queue
        // immediately, but the main Dart side hasn't registered its
        // channel handlers yet (widgets haven't built).  Instead, set up
        // the relay now and defer the connection signal until
        // `isChatHeadActive()` is called — that Pigeon call acts as an
        // implicit "ready" signal from the Dart side.
        val service = FloatyContentJobService.instance
        if (service != null) {
            isServiceRunning = true
            pendingConnectionSignal = true
            // Set up the relay so main→overlay messages work, but
            // do NOT notify the overlay of reconnection yet.
            service.onMainAppRelay()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Only the main engine plugin should clean up shared state.
        if (!isMainEnginePlugin) return

        FloatyHostApi.setUp(binding.binaryMessenger, null)
        mainMessenger?.setMessageHandler(null)
        mainMessenger = null
        activeInstance = null
        flutterPluginBinding = null
        isMainEnginePlugin = false
        pendingConnectionSignal = false

        // Notify the service that the main app is disconnected, but
        // keep the overlay engine alive.
        FloatyContentJobService.instance?.onMainAppDisconnected()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(
        binding: ActivityPluginBinding,
    ) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun checkPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(context)
        } else {
            true
        }
    }

    override fun requestPermission(callback: (Result<Boolean>) -> Unit) {
        val currentActivity = activity
        if (currentActivity == null) {
            callback(Result.success(false))
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (Settings.canDrawOverlays(currentActivity)) {
                callback(Result.success(true))
                return
            }
            pendingPermissionResult = callback
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:${currentActivity.packageName}"),
            )
            currentActivity.startActivityForResult(
                intent, PERMISSION_REQUEST_CODE,
            )
        } else {
            callback(Result.success(true))
        }
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?,
    ): Boolean {
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val granted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                Settings.canDrawOverlays(context)
            } else {
                true
            }
            pendingPermissionResult?.invoke(Result.success(granted))
            pendingPermissionResult = null
            return true
        }
        return false
    }

    override fun showChatHead(config: ChatHeadConfig) {
        val currentActivity = activity ?: return
        val appContext = currentActivity.applicationContext

        // Tear down any existing overlay so the new entry point takes
        // effect. Use closeWindow(false) to avoid stopping the service
        // — we are about to restart it immediately and stopSelf() is
        // asynchronous.
        if (isServiceRunning) {
            FloatyContentJobService.instance?.closeWindow(false)
        }
        isServiceRunning = false

        // Destroy any existing engine before creating a new one.
        FloatyContentJobService.instance?.destroyOverlayEngine()

        // Load icons: new multi-source fields take precedence over legacy
        // asset-path strings.  Network icons are loaded in parallel on
        // background threads to avoid blocking the main thread for up to
        // 3 × timeout seconds sequentially.
        //
        // Uses ExecutorService + Callable (API 1+) instead of
        // CompletableFuture (API 24+) to stay compatible with minSdk 23.
        val executor = java.util.concurrent.Executors.newFixedThreadPool(3)
        val chatheadIconFuture = executor.submit(java.util.concurrent.Callable {
            loadBitmapFromSource(appContext, config.chatheadIconSource, config.chatheadIconAsset)
        })
        val closeIconFuture = executor.submit(java.util.concurrent.Callable {
            loadBitmapFromSource(appContext, config.closeIconSource, config.closeIconAsset)
        })
        val closeBgFuture = executor.submit(java.util.concurrent.Callable {
            loadBitmapFromSource(appContext, config.closeBackgroundSource, config.closeBackgroundAsset)
        })
        // Wait for all three in parallel — worst case is 1 × timeout, not 3 ×.
        try {
            chatheadIconFuture.get(ICON_LOAD_TIMEOUT_MS, java.util.concurrent.TimeUnit.MILLISECONDS)
                ?.let { OverlayConfig.floatingIcon = it }
            closeIconFuture.get(ICON_LOAD_TIMEOUT_MS, java.util.concurrent.TimeUnit.MILLISECONDS)
                ?.let { OverlayConfig.closeIcon = it }
            closeBgFuture.get(ICON_LOAD_TIMEOUT_MS, java.util.concurrent.TimeUnit.MILLISECONDS)
                ?.let { OverlayConfig.backgroundCloseIcon = it }
        } catch (_: Exception) {
            OverlayConfig.logW("One or more icon loads timed out")
        } finally {
            executor.shutdown()
        }
        config.notificationIconAsset?.let { loadAssetBitmap(appContext, it) }
            ?.let { OverlayConfig.notificationIcon = it }
        config.notificationTitle?.let { OverlayConfig.notificationTitle = it }
        OverlayConfig.notificationDescription = config.notificationDescription
        OverlayConfig.contentWidth = config.contentWidth?.toInt()
        OverlayConfig.contentHeight = config.contentHeight?.toInt()

        // Snap behavior
        OverlayConfig.snapEdge = when (config.snapEdge) {
            ni.devotion.floaty_chatheads.generated.SnapEdgeMessage.BOTH ->
                SnapEdge.BOTH
            ni.devotion.floaty_chatheads.generated.SnapEdgeMessage.LEFT ->
                SnapEdge.LEFT
            ni.devotion.floaty_chatheads.generated.SnapEdgeMessage.RIGHT ->
                SnapEdge.RIGHT
            ni.devotion.floaty_chatheads.generated.SnapEdgeMessage.NONE ->
                SnapEdge.NONE
        }
        OverlayConfig.snapMargin = config.snapMargin.toFloat()

        // Persistent position
        OverlayConfig.persistPosition = config.persistPosition

        // Entrance animation
        OverlayConfig.entranceAnimation = when (config.entranceAnimation) {
            ni.devotion.floaty_chatheads.generated
                .EntranceAnimationMessage.NONE ->
                EntranceAnimation.NONE
            ni.devotion.floaty_chatheads.generated
                .EntranceAnimationMessage.POP ->
                EntranceAnimation.POP
            ni.devotion.floaty_chatheads.generated
                .EntranceAnimationMessage.SLIDE_FROM_EDGE ->
                EntranceAnimation.SLIDE_FROM_EDGE
            ni.devotion.floaty_chatheads.generated
                .EntranceAnimationMessage.FADE ->
                EntranceAnimation.FADE
        }

        // Debug mode
        OverlayConfig.debugMode = config.debugMode

        // Theme
        config.theme?.let { theme ->
            theme.badgeColor?.let { OverlayConfig.badgeColor = it.toInt() }
            theme.badgeTextColor?.let {
                OverlayConfig.badgeTextColor = it.toInt()
            }
            theme.bubbleBorderColor?.let {
                OverlayConfig.bubbleBorderColor = it.toInt()
            }
            theme.bubbleBorderWidth?.let {
                OverlayConfig.bubbleBorderWidth = it.toFloat()
            }
            theme.bubbleShadowColor?.let {
                OverlayConfig.bubbleShadowColor = it.toInt()
            }
            theme.closeTintColor?.let {
                OverlayConfig.closeTintColor = it.toInt()
            }
            theme.overlayPalette?.let { palette ->
                OverlayConfig.overlayPalette = palette
                    .filterKeys { it != null }
                    .filterValues { it != null }
                    .map { (k, v) -> k!! to v!!.toInt() }
                    .toMap()
            }
        }

        // Start service — it will create the engine.
        val serviceIntent = Intent(
            appContext, FloatyContentJobService::class.java,
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            appContext.startForegroundService(serviceIntent)
        } else {
            appContext.startService(serviceIntent)
        }

        // Tell the service to create the engine and window.
        // Note: the service may not have started yet (async), so we
        // also pass the entry point via SharedPreferences and let
        // the service's onCreate handle it if needed.
        val service = FloatyContentJobService.instance
        if (service != null) {
            // Tear down any stale window left over from a previous
            // session (e.g. START_STICKY restart with wrong dimensions
            // or a detached engine).  closeWindow(false) is a no-op
            // when chatHeads is already null.
            service.closeWindow(false)
            service.ensureOverlayEngine(config.entryPoint)
            service.persistConfig(config.entryPoint)
            pendingConnectionSignal = false
            service.onMainAppConnected()
            // Create the window NOW with the current OverlayConfig values
            // instead of relying on onStartCommand(), which skips
            // createWindow() when chatHeads is already non-null.
            service.createWindow()
        } else {
            // Service hasn't started yet — persist the FULL config so
            // its onCreate() -> restoreConfig() recovers all values
            // (especially content dimensions).  Previously only the
            // entry point was saved, causing dimensions to restore as
            // null -> MATCH_PARENT on every subsequent launch.
            ConfigPersistence(appContext).persist(config.entryPoint)
        }

        isServiceRunning = true
    }

    override fun closeChatHead() {
        FloatyContentJobService.instance?.closeWindow(true)
        isServiceRunning = false
    }

    override fun isChatHeadActive(): Boolean {
        // This Pigeon call from the Dart side confirms that the main
        // app's widget tree is built and channel handlers are registered.
        // If the overlay relay was set up during onAttachedToEngine
        // (deferred connection), now is the time to send `connected:true`
        // so the overlay flushes its action queue.
        if (isServiceRunning && pendingConnectionSignal) {
            pendingConnectionSignal = false
            FloatyContentJobService.instance?.onMainAppConnected()
        }
        return isServiceRunning
    }

    override fun addChatHead(config: AddChatHeadConfig) {
        val icon = loadBitmapFromSource(context!!, config.iconSource, config.iconAsset)
        FloatyContentJobService.instance?.addChatHead(config.id, icon)
    }

    override fun removeChatHead(id: String) {
        FloatyContentJobService.instance?.removeChatHead(id)
    }

    override fun updateBadge(count: Long) {
        FloatyContentJobService.instance?.chatHeads?.updateBadge(count.toInt())
    }

    override fun expandChatHead() {
        FloatyContentJobService.instance?.chatHeads?.expand()
    }

    override fun collapseChatHead() {
        FloatyContentJobService.instance?.chatHeads?.collapse()
    }

    private fun loadAssetBitmap(
        context: Context,
        assetPath: String,
    ): android.graphics.Bitmap? {
        return try {
            val flutterLoader = FlutterInjector.instance().flutterLoader()
            val lookupKey = flutterLoader.getLookupKeyForAsset(assetPath)
            val inputStream = context.assets.open(lookupKey)
            BitmapFactory.decodeStream(inputStream)
        } catch (e: IOException) {
            null
        }
    }

    private fun loadBitmapFromBytes(bytes: ByteArray): android.graphics.Bitmap? {
        return BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
    }

    /**
     * Loads a bitmap from a network URL.
     *
     * The HTTP request runs on the **calling thread** (which should be a
     * background thread — see `showChatHead` where an [ExecutorService] is
     * used). This method never blocks the main/UI thread directly.
     */
    private fun loadBitmapFromNetwork(url: String): android.graphics.Bitmap? {
        var connection: HttpURLConnection? = null
        return try {
            connection = URL(url).openConnection() as HttpURLConnection
            connection.doInput = true
            connection.connectTimeout = NETWORK_CONNECT_TIMEOUT_MS
            connection.readTimeout = NETWORK_READ_TIMEOUT_MS
            connection.connect()
            connection.inputStream.use { input ->
                BitmapFactory.decodeStream(input)
            }
        } catch (_: Exception) {
            null
        } finally {
            connection?.disconnect()
        }
    }

    // Resolves an icon from the new IconSourceMessage or falls back to a
    // legacy asset-path string.
    private fun loadBitmapFromSource(
        context: Context,
        source: IconSourceMessage?,
        legacyAsset: String?,
    ): android.graphics.Bitmap? {
        if (source != null) {
            val bitmap = when (source.type) {
                IconSourceTypeMessage.ASSET ->
                    source.path?.let { loadAssetBitmap(context, it) }
                IconSourceTypeMessage.NETWORK ->
                    source.path?.let { loadBitmapFromNetwork(it) }
                IconSourceTypeMessage.BYTES ->
                    source.bytes?.let { loadBitmapFromBytes(it) }
            }
            if (bitmap == null) {
                OverlayConfig.logW("Failed to load icon from ${source.type}: ${source.path ?: "bytes"}")
            }
            return bitmap
        }
        val bitmap = legacyAsset?.let { loadAssetBitmap(context, it) }
        if (legacyAsset != null && bitmap == null) {
            OverlayConfig.logW("Failed to load asset icon: $legacyAsset")
        }
        return bitmap
    }
}
