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
import ni.devotion.floaty_chatheads.services.FloatyContentJobService
import ni.devotion.floaty_chatheads.utils.Constants
import ni.devotion.floaty_chatheads.utils.EntranceAnimation
import ni.devotion.floaty_chatheads.utils.Managment
import ni.devotion.floaty_chatheads.utils.SnapEdge
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking

class FloatyChatheadsPlugin :
    FlutterPlugin,
    ActivityAware,
    FloatyHostApi,
    PluginRegistry.ActivityResultListener {

    companion object {
        private const val PERMISSION_REQUEST_CODE = 2084
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

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
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
        // reconnect to the existing overlay.
        val service = FloatyContentJobService.instance
        if (service != null) {
            isServiceRunning = true
            service.onMainAppConnected()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        FloatyHostApi.setUp(binding.binaryMessenger, null)
        mainMessenger?.setMessageHandler(null)
        mainMessenger = null
        activeInstance = null
        flutterPluginBinding = null

        // Notify the service that the main app is disconnected, but
        // keep the overlay engine alive.
        FloatyContentJobService.instance?.onMainAppDisconnected()
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

    override fun onReattachedToActivityForConfigChanges(
        binding: ActivityPluginBinding,
    ) {
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
        // asset-path strings.
        loadBitmapFromSource(appContext, config.chatheadIconSource, config.chatheadIconAsset)
            ?.let { Managment.floatingIcon = it }
        loadBitmapFromSource(appContext, config.closeIconSource, config.closeIconAsset)
            ?.let { Managment.closeIcon = it }
        loadBitmapFromSource(appContext, config.closeBackgroundSource, config.closeBackgroundAsset)
            ?.let { Managment.backgroundCloseIcon = it }
        config.notificationIconAsset?.let { loadAssetBitmap(appContext, it) }
            ?.let { Managment.notificationIcon = it }
        config.notificationTitle?.let { Managment.notificationTitle = it }
        Managment.contentWidth = config.contentWidth?.toInt()
        Managment.contentHeight = config.contentHeight?.toInt()

        // Snap behavior
        Managment.snapEdge = when (config.snapEdge) {
            ni.devotion.floaty_chatheads.generated.SnapEdgeMessage.BOTH ->
                SnapEdge.BOTH
            ni.devotion.floaty_chatheads.generated.SnapEdgeMessage.LEFT ->
                SnapEdge.LEFT
            ni.devotion.floaty_chatheads.generated.SnapEdgeMessage.RIGHT ->
                SnapEdge.RIGHT
            ni.devotion.floaty_chatheads.generated.SnapEdgeMessage.NONE ->
                SnapEdge.NONE
        }
        Managment.snapMargin = config.snapMargin.toFloat()

        // Persistent position
        Managment.persistPosition = config.persistPosition

        // Entrance animation
        Managment.entranceAnimation = when (config.entranceAnimation) {
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
        Managment.debugMode = config.debugMode

        // Theme
        config.theme?.let { theme ->
            theme.badgeColor?.let { Managment.badgeColor = it.toInt() }
            theme.badgeTextColor?.let {
                Managment.badgeTextColor = it.toInt()
            }
            theme.bubbleBorderColor?.let {
                Managment.bubbleBorderColor = it.toInt()
            }
            theme.bubbleBorderWidth?.let {
                Managment.bubbleBorderWidth = it.toFloat()
            }
            theme.bubbleShadowColor?.let {
                Managment.bubbleShadowColor = it.toInt()
            }
            theme.closeTintColor?.let {
                Managment.closeTintColor = it.toInt()
            }
            theme.overlayPalette?.let { palette ->
                Managment.overlayPalette = palette
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

        // Tell the service to create the engine and persist config.
        // Note: the service may not have started yet (async), so we
        // also pass the entry point via SharedPreferences and let
        // the service's onCreate handle it if needed.
        val service = FloatyContentJobService.instance
        if (service != null) {
            service.ensureOverlayEngine(config.entryPoint)
            service.persistConfig(config.entryPoint)
            service.onMainAppConnected()
        } else {
            // Service hasn't started yet — persist config so its
            // onCreate() can pick it up. The engine will be created
            // by the service in onCreate() → ensureOverlayEngine().
            val prefs = appContext.getSharedPreferences(
                Constants.PREFS_NAME, Context.MODE_PRIVATE,
            )
            prefs.edit().apply {
                putBoolean(Constants.PREF_HAS_SAVED_CONFIG, true)
                putString(Constants.PREF_ENTRY_POINT, config.entryPoint)
                apply()
            }
        }

        isServiceRunning = true
    }

    override fun closeChatHead() {
        FloatyContentJobService.instance?.closeWindow(true)
        isServiceRunning = false
    }

    override fun isChatHeadActive(): Boolean = isServiceRunning

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

    private fun loadBitmapFromNetwork(url: String): android.graphics.Bitmap? {
        return runBlocking(Dispatchers.IO) {
            try {
                val connection = URL(url).openConnection() as HttpURLConnection
                connection.doInput = true
                connection.connectTimeout = 10_000
                connection.readTimeout = 10_000
                connection.connect()
                val input = connection.inputStream
                val bitmap = BitmapFactory.decodeStream(input)
                input.close()
                connection.disconnect()
                bitmap
            } catch (e: Exception) {
                null
            }
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
            return when (source.type) {
                IconSourceTypeMessage.ASSET ->
                    source.path?.let { loadAssetBitmap(context, it) }
                IconSourceTypeMessage.NETWORK ->
                    source.path?.let { loadBitmapFromNetwork(it) }
                IconSourceTypeMessage.BYTES ->
                    source.bytes?.let { loadBitmapFromBytes(it) }
            }
        }
        return legacyAsset?.let { loadAssetBitmap(context, it) }
    }
}
