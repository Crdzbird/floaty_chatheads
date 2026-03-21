package ni.devotion.floaty_chatheads.services

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.FlutterInjector
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.JSONMessageCodec
import ni.devotion.floaty_chatheads.FloatyChatheadsPlugin
import ni.devotion.floaty_chatheads.utils.Constants
import ni.devotion.floaty_chatheads.utils.OverlayConfig

/**
 * Manages the overlay Flutter engine lifecycle: creation, caching,
 * messenger setup, and destruction.
 */
internal class OverlayEngineManager(private val context: Context) {

    /** The overlay-side messenger for main <-> overlay communication. */
    var overlayMessenger: BasicMessageChannel<Any?>? = null
        private set

    /** Whether the main app plugin is currently attached. */
    var mainAppConnected: Boolean = false
        private set

    /**
     * Creates (or reuses) the overlay Flutter engine and sets up the
     * messenger relay.
     */
    fun ensureEngine(entryPoint: String) {
        val existing = FlutterEngineCache.getInstance()
            .get(Constants.OVERLAY_ENGINE_CACHE_TAG)
        if (existing != null) {
            OverlayConfig.logD("ensureEngine: engine already cached")
            setupMessenger(existing)
            return
        }

        OverlayConfig.logD("ensureEngine: creating engine for '$entryPoint'")
        val engineGroup = FlutterEngineGroup(context)
        val dartEntrypoint = DartExecutor.DartEntrypoint(
            FlutterInjector.instance().flutterLoader().findAppBundlePath(),
            entryPoint,
        )
        val engine = engineGroup.createAndRunEngine(context, dartEntrypoint)
        FlutterEngineCache.getInstance()
            .put(Constants.OVERLAY_ENGINE_CACHE_TAG, engine)

        setupMessenger(engine)

        // Send theme palette to overlay isolate if configured.
        OverlayConfig.overlayPalette?.let { palette ->
            overlayMessenger?.send(
                mapOf(
                    Constants.SYSTEM_ENVELOPE to Constants.THEME_PREFIX,
                    Constants.THEME_PREFIX to palette,
                ),
            )
        }
    }

    /**
     * Sets up the overlay-side BasicMessageChannel and relay.
     */
    fun setupMessenger(engine: FlutterEngine) {
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

    /** Destroys the overlay engine and cleans up the messenger. */
    fun destroyEngine() {
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

    /** Returns the cached engine, if any. */
    fun cachedEngine(): FlutterEngine? =
        FlutterEngineCache.getInstance().get(Constants.OVERLAY_ENGINE_CACHE_TAG)

    /** Marks the main app as connected and re-establishes the relay. */
    fun onMainAppConnected() {
        mainAppConnected = true
        val engine = cachedEngine()
        if (engine != null) {
            setupMessenger(engine)
        }
        overlayMessenger?.send(
            mapOf(
                Constants.SYSTEM_ENVELOPE to Constants.CONNECTION_PREFIX,
                Constants.CONNECTION_PREFIX to mapOf("connected" to true),
            ),
        )
    }

    /**
     * Sets up the relay (so main→overlay forwarding works) and marks the
     * main app as connected, but does NOT send the `connected:true`
     * signal to the overlay.  The overlay will keep queueing actions
     * until [onMainAppConnected] is called later (e.g. from
     * `isChatHeadActive()`).
     */
    fun onMainAppRelay() {
        mainAppConnected = true
        val engine = cachedEngine()
        if (engine != null) {
            setupMessenger(engine)
        }
        // No `connected:true` send here — deferred.
    }

    /** Marks the main app as disconnected. */
    fun onMainAppDisconnected() {
        mainAppConnected = false
        overlayMessenger?.send(
            mapOf(
                Constants.SYSTEM_ENVELOPE to Constants.CONNECTION_PREFIX,
                Constants.CONNECTION_PREFIX to mapOf("connected" to false),
            ),
        )
        val engine = cachedEngine()
        if (engine != null) {
            overlayMessenger?.setMessageHandler { _, reply ->
                reply.reply(null)
            }
        }
    }
}
