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
import ni.devotion.floaty_chatheads.services.FloatyContentJobService
import ni.devotion.floaty_chatheads.utils.Constants
import ni.devotion.floaty_chatheads.utils.EntranceAnimation
import ni.devotion.floaty_chatheads.utils.Managment
import ni.devotion.floaty_chatheads.utils.SnapEdge
import java.io.IOException

class FloatyChatheadsPlugin :
    FlutterPlugin,
    ActivityAware,
    FloatyHostApi,
    PluginRegistry.ActivityResultListener {

    companion object {
        private const val PERMISSION_REQUEST_CODE = 2084
        var isServiceRunning = false
    }

    private var activity: Activity? = null
    private var context: Context? = null
    private var mainMessenger: BasicMessageChannel<Any?>? = null
    private var overlayMessenger: BasicMessageChannel<Any?>? = null
    private var pendingPermissionResult: ((Result<Boolean>) -> Unit)? = null
    private var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBinding = binding
        context = binding.applicationContext
        FloatyHostApi.setUp(binding.binaryMessenger, this)

        mainMessenger = BasicMessageChannel(
            binding.binaryMessenger,
            Constants.MESSENGER_TAG,
            JSONMessageCodec.INSTANCE,
        )
        // Main → Overlay relay: forward messages from the main Dart to the overlay Dart.
        mainMessenger?.setMessageHandler { message, reply ->
            if (overlayMessenger != null) {
                overlayMessenger?.send(message, reply)
            } else {
                reply.reply(null)
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        FloatyHostApi.setUp(binding.binaryMessenger, null)
        mainMessenger?.setMessageHandler(null)
        mainMessenger = null
        flutterPluginBinding = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        Managment.activity = binding.activity
        Managment.globalContext = binding.activity.applicationContext
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        Managment.activity = binding.activity
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
            currentActivity.startActivityForResult(intent, PERMISSION_REQUEST_CODE)
        } else {
            callback(Result.success(true))
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
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

        // Tear down any existing overlay so the new entry point takes effect.
        // Use closeWindow(false) to avoid stopping the service — we are about
        // to restart it immediately and stopSelf() is asynchronous.  If the
        // service's onDestroy fires after the new startForegroundService, it
        // sets instance = null, orphaning the freshly-created window.
        if (isServiceRunning) {
            FloatyContentJobService.instance?.closeWindow(false)
        }
        isServiceRunning = false
        destroyOverlayEngine()

        config.chatheadIconAsset?.let { loadAssetBitmap(appContext, it) }
            ?.let { Managment.floatingIcon = it }
        config.closeIconAsset?.let { loadAssetBitmap(appContext, it) }
            ?.let { Managment.closeIcon = it }
        config.closeBackgroundAsset?.let { loadAssetBitmap(appContext, it) }
            ?.let { Managment.backgroundCloseIcon = it }
        config.notificationIconAsset?.let { loadAssetBitmap(appContext, it) }
            ?.let { Managment.notificationIcon = it }
        config.notificationTitle?.let { Managment.notificationTitle = it }
        Managment.contentWidth = config.contentWidth?.toInt()
        Managment.contentHeight = config.contentHeight?.toInt()

        // Snap behavior
        Managment.snapEdge = when (config.snapEdge) {
            ni.devotion.floaty_chatheads.generated.SnapEdgeMessage.BOTH -> SnapEdge.BOTH
            ni.devotion.floaty_chatheads.generated.SnapEdgeMessage.LEFT -> SnapEdge.LEFT
            ni.devotion.floaty_chatheads.generated.SnapEdgeMessage.RIGHT -> SnapEdge.RIGHT
            ni.devotion.floaty_chatheads.generated.SnapEdgeMessage.NONE -> SnapEdge.NONE
        }
        Managment.snapMargin = config.snapMargin.toFloat()

        // Persistent position
        Managment.persistPosition = config.persistPosition

        // Entrance animation
        Managment.entranceAnimation = when (config.entranceAnimation) {
            ni.devotion.floaty_chatheads.generated.EntranceAnimationMessage.NONE -> EntranceAnimation.NONE
            ni.devotion.floaty_chatheads.generated.EntranceAnimationMessage.POP -> EntranceAnimation.POP
            ni.devotion.floaty_chatheads.generated.EntranceAnimationMessage.SLIDE_FROM_EDGE -> EntranceAnimation.SLIDE_FROM_EDGE
            ni.devotion.floaty_chatheads.generated.EntranceAnimationMessage.FADE -> EntranceAnimation.FADE
        }

        // Debug mode
        Managment.debugMode = config.debugMode

        // Theme
        config.theme?.let { theme ->
            theme.badgeColor?.let { Managment.badgeColor = it.toInt() }
            theme.badgeTextColor?.let { Managment.badgeTextColor = it.toInt() }
            theme.bubbleBorderColor?.let { Managment.bubbleBorderColor = it.toInt() }
            theme.bubbleBorderWidth?.let { Managment.bubbleBorderWidth = it.toFloat() }
            theme.bubbleShadowColor?.let { Managment.bubbleShadowColor = it.toInt() }
            theme.closeTintColor?.let { Managment.closeTintColor = it.toInt() }
            theme.overlayPalette?.let { palette ->
                Managment.overlayPalette = palette
                    .filterKeys { it != null }
                    .filterValues { it != null }
                    .map { (k, v) -> k!! to v!!.toInt() }
                    .toMap()
            }
        }

        createOverlayEngine(appContext, config.entryPoint)

        val serviceIntent = Intent(appContext, FloatyContentJobService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            appContext.startForegroundService(serviceIntent)
        } else {
            appContext.startService(serviceIntent)
        }
        isServiceRunning = true
    }

    override fun closeChatHead() {
        FloatyContentJobService.instance?.closeWindow(true)
        isServiceRunning = false
        destroyOverlayEngine()
    }

    override fun isChatHeadActive(): Boolean = isServiceRunning

    override fun addChatHead(config: AddChatHeadConfig) {
        val icon = config.iconAsset?.let { loadAssetBitmap(context!!, it) }
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

    private fun createOverlayEngine(context: Context, entryPoint: String) {
        // Always start fresh — destroyOverlayEngine() must be called before this.
        val engineGroup = FlutterEngineGroup(context)
        val dartEntrypoint = DartExecutor.DartEntrypoint(
            FlutterInjector.instance().flutterLoader().findAppBundlePath(),
            entryPoint,
        )
        val engine = engineGroup.createAndRunEngine(context, dartEntrypoint)
        FlutterEngineCache.getInstance().put(Constants.OVERLAY_ENGINE_CACHE_TAG, engine)

        // Set up the Overlay → Main relay so messages from the overlay Dart
        // are forwarded to the main Dart side.
        overlayMessenger = BasicMessageChannel(
            engine.dartExecutor,
            Constants.MESSENGER_TAG,
            JSONMessageCodec.INSTANCE,
        )
        overlayMessenger?.setMessageHandler { message, reply ->
            mainMessenger?.send(message, reply) ?: reply.reply(null)
        }

        // Send theme palette to overlay isolate if configured.
        Managment.overlayPalette?.let { palette ->
            overlayMessenger?.send(mapOf("_floaty_theme" to palette))
        }
    }

    private fun destroyOverlayEngine() {
        overlayMessenger?.setMessageHandler(null)
        overlayMessenger = null

        val engine = FlutterEngineCache.getInstance().get(Constants.OVERLAY_ENGINE_CACHE_TAG)
        if (engine != null) {
            FlutterEngineCache.getInstance().remove(Constants.OVERLAY_ENGINE_CACHE_TAG)
            engine.destroy()
        }
    }

    private fun loadAssetBitmap(context: Context, assetPath: String): android.graphics.Bitmap? {
        return try {
            val flutterLoader = FlutterInjector.instance().flutterLoader()
            val lookupKey = flutterLoader.getLookupKeyForAsset(assetPath)
            val inputStream = context.assets.open(lookupKey)
            BitmapFactory.decodeStream(inputStream)
        } catch (e: IOException) {
            null
        }
    }
}
