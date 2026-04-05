package ni.devotion.floaty_chatheads

import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Bundle
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
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.async
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
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
    private var lifecycleCallbacks: AutoLaunchLifecycleCallbacks? = null

    /**
     * True while [showChatHead] is setting up the overlay (between
     * `startForegroundService` and the coroutine completing).
     * When set, [FloatyContentJobService.onStartCommand] must NOT
     * call `createWindow()` — the coroutine will do it after icons
     * are loaded and OverlayConfig is fully populated.
     */
    internal var pluginSetupInProgress = false

    /**
     * Coroutine scope tied to the plugin's engine attachment lifecycle.
     * Cancelled in [onDetachedFromEngine] to prevent leaks.
     */
    private var pluginScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

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
        pluginScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
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
        removeAutoLaunchCallbacks()
        pluginScope.cancel()

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

    override fun showChatHead(
        config: ChatHeadConfig,
        callback: (Result<Unit>) -> Unit,
    ) {
        val currentActivity = activity ?: run {
            callback(Result.success(Unit))
            return
        }
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

        // Populate OverlayConfig synchronously so the values are
        // available when the service starts.
        config.notificationTitle?.let { OverlayConfig.notificationTitle = it }
        OverlayConfig.notificationDescription = config.notificationDescription
        OverlayConfig.contentWidth = config.contentWidth?.toInt()
        OverlayConfig.contentHeight = config.contentHeight?.toInt()

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
        OverlayConfig.persistPosition = config.persistPosition
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
        OverlayConfig.debugMode = config.debugMode
        OverlayConfig.autoLaunchOnBackground = config.autoLaunchOnBackground
        OverlayConfig.persistOnAppClose = config.persistOnAppClose
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

        // Start the service BEFORE icon loading so that onCreate()
        // runs on the main thread while the coroutine suspends for
        // I/O. This guarantees FloatyContentJobService.instance is
        // non-null by the time icons are loaded. The service's
        // onStartCommand() is guarded (pluginSetupInProgress) to
        // avoid creating the window prematurely.
        pluginSetupInProgress = true
        val serviceIntent = Intent(
            appContext, FloatyContentJobService::class.java,
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            appContext.startForegroundService(serviceIntent)
        } else {
            appContext.startService(serviceIntent)
        }

        // Load icons in parallel on Dispatchers.IO. While the
        // coroutine suspends here, the main thread processes the
        // service start (onCreate sets instance). The Pigeon callback
        // is invoked only after the window is fully created.
        pluginScope.launch {
            val chatheadIcon = async(Dispatchers.IO) {
                withTimeoutOrNull(ICON_LOAD_TIMEOUT_MS) {
                    loadBitmapFromSource(appContext, config.chatheadIconSource, config.chatheadIconAsset)
                }
            }
            val closeIcon = async(Dispatchers.IO) {
                withTimeoutOrNull(ICON_LOAD_TIMEOUT_MS) {
                    loadBitmapFromSource(appContext, config.closeIconSource, config.closeIconAsset)
                }
            }
            val closeBg = async(Dispatchers.IO) {
                withTimeoutOrNull(ICON_LOAD_TIMEOUT_MS) {
                    loadBitmapFromSource(appContext, config.closeBackgroundSource, config.closeBackgroundAsset)
                }
            }

            // Await all three in parallel — worst case is 1 × timeout.
            chatheadIcon.await()?.let { OverlayConfig.floatingIcon = it }
            closeIcon.await()?.let { OverlayConfig.closeIcon = it }
            closeBg.await()?.let { OverlayConfig.backgroundCloseIcon = it }

            // Notification icon is always an asset — fast, no network.
            withContext(Dispatchers.IO) {
                config.notificationIconAsset?.let { loadAssetBitmap(appContext, it) }
                    ?.let { OverlayConfig.notificationIcon = it }
            }

            // Back on Main — service.instance is guaranteed non-null
            // because onCreate() ran while we were loading icons.
            val service = FloatyContentJobService.instance
            if (service != null) {
                service.closeWindow(false)
                service.ensureOverlayEngine(config.entryPoint)
                service.persistConfig(config.entryPoint)
                pendingConnectionSignal = false
                service.onMainAppConnected()
                service.createWindow()
            } else {
                // Fallback: service not ready (should not happen).
                ConfigPersistence(appContext).persist(config.entryPoint)
            }

            isServiceRunning = true
            pluginSetupInProgress = false

            // Register / unregister auto-launch lifecycle callbacks.
            updateAutoLaunchCallbacks(appContext)

            // Signal the Dart side that the chathead is fully ready.
            callback(Result.success(Unit))
        }
    }

    override fun closeChatHead() {
        removeAutoLaunchCallbacks()
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

    override fun addChatHead(
        config: AddChatHeadConfig,
        callback: (Result<Unit>) -> Unit,
    ) {
        val ctx = context ?: run {
            callback(Result.success(Unit))
            return
        }
        pluginScope.launch {
            val icon = withContext(Dispatchers.IO) {
                loadBitmapFromSource(ctx, config.iconSource, config.iconAsset)
            }
            FloatyContentJobService.instance?.addChatHead(config.id, icon)
            callback(Result.success(Unit))
        }
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

    // ── Auto-launch lifecycle management ─────────────────────────────

    private fun updateAutoLaunchCallbacks(appContext: Context) {
        val app = appContext as? Application ?: return
        // Remove previous callbacks before (re-)registering.
        removeAutoLaunchCallbacks()
        if (OverlayConfig.autoLaunchOnBackground) {
            val callbacks = AutoLaunchLifecycleCallbacks(this)
            app.registerActivityLifecycleCallbacks(callbacks)
            lifecycleCallbacks = callbacks
        }
    }

    private fun removeAutoLaunchCallbacks() {
        lifecycleCallbacks?.let { cb ->
            (context as? Application)?.unregisterActivityLifecycleCallbacks(cb)
            lifecycleCallbacks = null
        }
    }

    /**
     * Called by [AutoLaunchLifecycleCallbacks] when all activities have moved
     * to the background. Shows the chathead if it is not already visible.
     */
    internal fun onAppBackgrounded() {
        if (!OverlayConfig.autoLaunchOnBackground) return
        if (isServiceRunning) return
        val appContext = context ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
            !Settings.canDrawOverlays(appContext)
        ) return

        // Start the service and create the overlay from persisted config.
        val serviceIntent = Intent(appContext, FloatyContentJobService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            appContext.startForegroundService(serviceIntent)
        } else {
            appContext.startService(serviceIntent)
        }

        val service = FloatyContentJobService.instance
        if (service != null) {
            val entryPoint = ConfigPersistence(appContext).readEntryPoint() ?: return
            service.ensureOverlayEngine(entryPoint)
            service.onMainAppConnected()
            service.createWindow()
        }
        isServiceRunning = true
    }

    /**
     * Called by [AutoLaunchLifecycleCallbacks] when the app returns to the
     * foreground. Closes the auto-launched chathead.
     */
    internal fun onAppForegrounded() {
        if (!OverlayConfig.autoLaunchOnBackground) return
        if (!isServiceRunning) return
        FloatyContentJobService.instance?.closeWindow(true)
        isServiceRunning = false
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

/**
 * Tracks how many activities are in the started state. When the count drops
 * to zero the app is considered backgrounded; when it rises from zero the
 * app is foregrounded.
 *
 * This mirrors the approach used by `ProcessLifecycleOwner` but avoids
 * pulling in the `lifecycle-process` dependency.
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
