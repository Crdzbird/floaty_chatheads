package ni.devotion.floaty_chatheads

import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.JSONMessageCodec
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.async
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import ni.devotion.floaty_chatheads.generated.AddChatHeadConfig
import ni.devotion.floaty_chatheads.generated.ChatHeadConfig
import ni.devotion.floaty_chatheads.generated.FloatyHostApi
import ni.devotion.floaty_chatheads.generated.FlutterError
import ni.devotion.floaty_chatheads.generated.NotificationVisibilityMessage
import ni.devotion.floaty_chatheads.generated.IconSourceTypeMessage
import ni.devotion.floaty_chatheads.services.AutoLaunchLifecycleCallbacks
import ni.devotion.floaty_chatheads.services.ConfigPersistence
import ni.devotion.floaty_chatheads.services.FloatyContentJobService
import ni.devotion.floaty_chatheads.services.IconFrame
import ni.devotion.floaty_chatheads.services.IconFrameRenderer
import ni.devotion.floaty_chatheads.services.OverlayEngineManager
import ni.devotion.floaty_chatheads.services.OverlayIconLoader
import ni.devotion.floaty_chatheads.services.OverlayPermissionHandler
import ni.devotion.floaty_chatheads.utils.Constants
import ni.devotion.floaty_chatheads.utils.EntranceAnimation
import ni.devotion.floaty_chatheads.utils.NotificationVisibility
import ni.devotion.floaty_chatheads.utils.OverlayConfig
import ni.devotion.floaty_chatheads.utils.PanelAnchor
import ni.devotion.floaty_chatheads.utils.SnapEdge

class FloatyChatheadsPlugin :
    FlutterPlugin,
    ActivityAware,
    FloatyHostApi,
    PluginRegistry.ActivityResultListener {

    companion object {
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
    private var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null
    private var lifecycleCallbacks: AutoLaunchLifecycleCallbacks? = null

    private val permissions = OverlayPermissionHandler()
    private val iconRenderers = mutableMapOf<String, IconFrameRenderer>()
    private val pendingIconFrames = LinkedHashMap<String, IconFrame>()
    private var iconFrameInFlight = false

    /**
     * True while [showChatHead] is setting up the overlay (between
     * `startForegroundService` and the coroutine completing).
     * When set, [FloatyContentJobService.onStartCommand] must NOT
     * call `createWindow()`; the coroutine will do it after icons
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
     * When [io.flutter.embedding.engine.FlutterEngineGroup.createAndRunEngine]
     * creates the overlay engine it auto-registers all plugins, including
     * this one.  The overlay instance must NOT overwrite [activeInstance]
     * or [mainMessenger], since doing so would cause overlay to main messages to
     * loop back to the overlay instead of reaching the main Dart side.
     */
    private var isMainEnginePlugin = false

    /**
     * Sets up the host API and the main to overlay messenger relay. Only
     * the first attachment (the main engine) does this; attachments from
     * the overlay engine, including restore after death, are ignored.
     * When the service is already running, the relay is wired but the
     * `connected:true` signal is deferred until [isChatHeadActive].
     */
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        if (activeInstance != null || OverlayEngineManager.creatingOverlayEngine) {
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
        mainMessenger?.setMessageHandler { message, reply ->
            val service = FloatyContentJobService.instance
            if (service?.overlayMessenger != null) {
                service.overlayMessenger?.send(message, reply)
            } else {
                reply.reply(null)
            }
        }

        val service = FloatyContentJobService.instance
        if (service != null) {
            isServiceRunning = true
            pendingConnectionSignal = true
            service.onMainAppRelay()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
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

    override fun checkPermission(): Boolean = permissions.check(context)

    override fun requestPermission(callback: (Result<Boolean>) -> Unit) =
        permissions.request(activity, callback)

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?,
    ): Boolean = permissions.handleActivityResult(requestCode, context)

    override fun showChatHead(
        config: ChatHeadConfig,
        callback: (Result<Unit>) -> Unit,
    ) {
        val appContext = context ?: run {
            callback(
                Result.failure(
                    FlutterError(
                        "not_attached",
                        "floaty_chatheads is not attached to a Flutter engine.",
                        null,
                    ),
                ),
            )
            return
        }
        permissions.requestNotificationPermission(activity)

        if (isServiceRunning) {
            FloatyContentJobService.instance?.closeWindow(false)
        }
        isServiceRunning = false

        applyConfigToOverlayConfig(config)

        pluginSetupInProgress = true
        startOverlayService(appContext)

        pluginScope.launch {
            val chatheadIcon = async(Dispatchers.IO) {
                withTimeoutOrNull(OverlayIconLoader.ICON_LOAD_TIMEOUT_MS) {
                    OverlayIconLoader.loadFromSource(
                        appContext, config.chatheadIconSource, config.chatheadIconAsset,
                    )
                }
            }
            val closeIcon = async(Dispatchers.IO) {
                withTimeoutOrNull(OverlayIconLoader.ICON_LOAD_TIMEOUT_MS) {
                    OverlayIconLoader.loadFromSource(
                        appContext, config.closeIconSource, config.closeIconAsset,
                    )
                }
            }
            val closeBg = async(Dispatchers.IO) {
                withTimeoutOrNull(OverlayIconLoader.ICON_LOAD_TIMEOUT_MS) {
                    OverlayIconLoader.loadFromSource(
                        appContext, config.closeBackgroundSource, config.closeBackgroundAsset,
                    )
                }
            }

            chatheadIcon.await()?.let { OverlayConfig.floatingIcon = it }
            closeIcon.await()?.let { OverlayConfig.closeIcon = it }
            closeBg.await()?.let { OverlayConfig.backgroundCloseIcon = it }

            OverlayConfig.closeIconIsWidget =
                config.closeIconSource?.type == IconSourceTypeMessage.BYTES

            withContext(Dispatchers.IO) {
                config.notificationIconAsset
                    ?.let { OverlayIconLoader.loadAsset(appContext, it) }
                    ?.let { OverlayConfig.notificationIcon = it }
            }

            val service = FloatyContentJobService.instance
            if (service != null) {
                service.closeWindow(false)
                service.ensureOverlayEngine(config.entryPoint)
                service.persistConfig(config.entryPoint)
                pendingConnectionSignal = false
                service.onMainAppConnected()
                service.createWindow()
            } else {
                ConfigPersistence(appContext).persist(config.entryPoint)
            }

            isServiceRunning = true
            pluginSetupInProgress = false

            updateAutoLaunchCallbacks(appContext)

            callback(Result.success(Unit))
        }
    }

    override fun closeChatHead() {
        releaseIconRenderers()
        removeAutoLaunchCallbacks()
        FloatyContentJobService.instance?.closeWindow(true)
        isServiceRunning = false
    }

    /**
     * Returns whether the overlay service is running. The first call after
     * a deferred reconnect also sends the pending `connected:true` signal,
     * since it confirms the main Dart side has registered its handlers.
     */
    override fun isChatHeadActive(): Boolean {
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
                OverlayIconLoader.loadFromSource(ctx, config.iconSource, config.iconAsset)
            }
            FloatyContentJobService.instance?.addChatHead(config.id, icon)
            callback(Result.success(Unit))
        }
    }

    override fun removeChatHead(id: String) {
        releaseIconRenderers(id)
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

    override fun updateChatHeadIcon(
        id: String,
        rgbaBytes: ByteArray,
        width: Long,
        height: Long,
    ) {
        if (!IconFrameRenderer.isValidFrame(width, height, rgbaBytes.size)) {
            android.util.Log.w(
                "FloatyChatheads",
                "updateChatHeadIcon: invalid dimensions " +
                    "${width}x$height (size=${rgbaBytes.size})",
            )
            return
        }
        pendingIconFrames[id] = IconFrame(rgbaBytes, width.toInt(), height.toInt())
        drainIconFrames()
    }

    /**
     * Renders at most one icon frame at a time. Frames that arrive while a
     * render is running replace the pending frame for their bubble, so a
     * slow device drops intermediate frames instead of queueing them.
     */
    private fun drainIconFrames() {
        if (iconFrameInFlight) return
        val id = pendingIconFrames.keys.firstOrNull() ?: return
        val frame = pendingIconFrames.remove(id) ?: return
        val renderer = iconRenderers.getOrPut(id) { IconFrameRenderer() }
        iconFrameInFlight = true
        pluginScope.launch {
            try {
                val bitmap = withContext(Dispatchers.Default) { renderer.render(frame) }
                FloatyContentJobService.instance?.chatHeads?.updateChatHeadIcon(id, bitmap)
            } finally {
                iconFrameInFlight = false
            }
            drainIconFrames()
        }
    }

    private fun releaseIconRenderers(id: String? = null) {
        if (id == null) {
            iconRenderers.clear()
            pendingIconFrames.clear()
            return
        }
        iconRenderers.remove(id)
        pendingIconFrames.remove(id)
    }

    private fun startOverlayService(appContext: Context) {
        val serviceIntent = Intent(appContext, FloatyContentJobService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            appContext.startForegroundService(serviceIntent)
        } else {
            appContext.startService(serviceIntent)
        }
    }

    /**
     * Copies the Pigeon-side [config] into the shared [OverlayConfig]
     * singleton so it is observable from native views when the service
     * starts. Synchronous on purpose: the service reads these values
     * from `onCreate` and the chatHeads view from `onDraw`.
     */
    private fun applyConfigToOverlayConfig(config: ChatHeadConfig) {
        config.notificationTitle?.let { OverlayConfig.notificationTitle = it }
        OverlayConfig.notificationDescription = config.notificationDescription
        OverlayConfig.notificationVisibility = when (config.notificationVisibility) {
            NotificationVisibilityMessage.VISIBILITY_PUBLIC -> NotificationVisibility.PUBLIC
            NotificationVisibilityMessage.VISIBILITY_SECRET -> NotificationVisibility.SECRET
            NotificationVisibilityMessage.VISIBILITY_PRIVATE -> NotificationVisibility.PRIVATE
        }
        OverlayConfig.entryPointLibrary = config.entryPointLibrary
        OverlayConfig.contentWidth = config.contentWidth?.toInt()
        OverlayConfig.contentHeight = config.contentHeight?.toInt()

        OverlayConfig.snapEdge = when (config.snapEdge) {
            ni.devotion.floaty_chatheads.generated.SnapEdgeMessage.BOTH -> SnapEdge.BOTH
            ni.devotion.floaty_chatheads.generated.SnapEdgeMessage.LEFT -> SnapEdge.LEFT
            ni.devotion.floaty_chatheads.generated.SnapEdgeMessage.RIGHT -> SnapEdge.RIGHT
            ni.devotion.floaty_chatheads.generated.SnapEdgeMessage.NONE -> SnapEdge.NONE
        }
        OverlayConfig.snapMargin = config.snapMargin.toFloat()
        OverlayConfig.persistPosition = config.persistPosition
        OverlayConfig.entranceAnimation = when (config.entranceAnimation) {
            ni.devotion.floaty_chatheads.generated.EntranceAnimationMessage.NONE ->
                EntranceAnimation.NONE
            ni.devotion.floaty_chatheads.generated.EntranceAnimationMessage.POP ->
                EntranceAnimation.POP
            ni.devotion.floaty_chatheads.generated.EntranceAnimationMessage.SLIDE_FROM_EDGE ->
                EntranceAnimation.SLIDE_FROM_EDGE
            ni.devotion.floaty_chatheads.generated.EntranceAnimationMessage.FADE ->
                EntranceAnimation.FADE
        }
        OverlayConfig.panelAnchor = when (config.panelAnchor) {
            ni.devotion.floaty_chatheads.generated.PanelAnchorMessage.BELOW ->
                PanelAnchor.BELOW
            ni.devotion.floaty_chatheads.generated.PanelAnchorMessage.ABOVE ->
                PanelAnchor.ABOVE
            ni.devotion.floaty_chatheads.generated.PanelAnchorMessage.AUTO ->
                PanelAnchor.AUTO
        }
        OverlayConfig.debugMode = config.debugMode
        OverlayConfig.autoLaunchOnBackground = config.autoLaunchOnBackground
        OverlayConfig.persistOnAppClose = config.persistOnAppClose
        config.theme?.let { theme ->
            theme.badgeColor?.let { OverlayConfig.badgeColor = it.toInt() }
            theme.badgeTextColor?.let { OverlayConfig.badgeTextColor = it.toInt() }
            theme.bubbleBorderColor?.let { OverlayConfig.bubbleBorderColor = it.toInt() }
            theme.bubbleBorderWidth?.let { OverlayConfig.bubbleBorderWidth = it.toFloat() }
            theme.bubbleShadowColor?.let { OverlayConfig.bubbleShadowColor = it.toInt() }
            theme.closeTintColor?.let { OverlayConfig.closeTintColor = it.toInt() }
            theme.overlayPalette?.let { palette ->
                OverlayConfig.overlayPalette = palette
                    .filterKeys { it != null }
                    .filterValues { it != null }
                    .map { (k, v) -> k!! to v!!.toInt() }
                    .toMap()
            }
        }
    }

    private fun updateAutoLaunchCallbacks(appContext: Context) {
        val app = appContext as? Application ?: return
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

        startOverlayService(appContext)

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
}
