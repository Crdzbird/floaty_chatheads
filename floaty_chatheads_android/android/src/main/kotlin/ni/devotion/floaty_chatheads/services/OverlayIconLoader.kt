package ni.devotion.floaty_chatheads.services

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.FlutterInjector
import ni.devotion.floaty_chatheads.generated.IconSourceMessage
import ni.devotion.floaty_chatheads.generated.IconSourceTypeMessage
import ni.devotion.floaty_chatheads.utils.OverlayConfig
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL

/**
 * Loads bitmaps from the three supported icon sources used by the plugin:
 * Flutter asset paths, network URLs, and in-memory byte arrays. All
 * methods are blocking and must be called from a background dispatcher.
 *
 * Network loads enforce a connect/read timeout pair to bound the worst
 * case at roughly [ICON_LOAD_TIMEOUT_MS].
 */
internal object OverlayIconLoader {
    /** Timeout (ms) for each icon load (network connect + read + decode). */
    const val ICON_LOAD_TIMEOUT_MS = 4_000L
    private const val NETWORK_CONNECT_TIMEOUT_MS = 3_000
    private const val NETWORK_READ_TIMEOUT_MS = 3_000

    /**
     * Resolves an icon from the new [IconSourceMessage], falling back to
     * a legacy asset-path string when the new field is null.
     *
     * Returns null when both inputs are null or when decoding fails.
     */
    fun loadFromSource(
        context: Context,
        source: IconSourceMessage?,
        legacyAsset: String?,
    ): Bitmap? {
        if (source != null) {
            val bitmap = when (source.type) {
                IconSourceTypeMessage.ASSET ->
                    source.path?.let { loadAsset(context, it) }
                IconSourceTypeMessage.NETWORK ->
                    source.path?.let { loadNetwork(it) }
                IconSourceTypeMessage.BYTES ->
                    source.bytes?.let { loadBytes(it) }
            }
            if (bitmap == null) {
                OverlayConfig.logW(
                    "Failed to load icon from ${source.type}: ${source.path ?: "bytes"}",
                )
            }
            return bitmap
        }
        val bitmap = legacyAsset?.let { loadAsset(context, it) }
        if (legacyAsset != null && bitmap == null) {
            OverlayConfig.logW("Failed to load asset icon: $legacyAsset")
        }
        return bitmap
    }

    /** Loads a Flutter asset by lookup key. Public for direct callers
     *  (e.g. notification icon path that bypasses [IconSourceMessage]). */
    fun loadAsset(context: Context, assetPath: String): Bitmap? = try {
        val flutterLoader = FlutterInjector.instance().flutterLoader()
        val lookupKey = flutterLoader.getLookupKeyForAsset(assetPath)
        context.assets.open(lookupKey).use { BitmapFactory.decodeStream(it) }
    } catch (_: IOException) {
        null
    }

    private fun loadBytes(bytes: ByteArray): Bitmap? =
        BitmapFactory.decodeByteArray(bytes, 0, bytes.size)

    /**
     * Loads a bitmap from a network URL. Blocks on the calling thread —
     * the caller is responsible for dispatching this off the UI thread.
     */
    private fun loadNetwork(url: String): Bitmap? {
        var connection: HttpURLConnection? = null
        return try {
            connection = (URL(url).openConnection() as HttpURLConnection).apply {
                doInput = true
                connectTimeout = NETWORK_CONNECT_TIMEOUT_MS
                readTimeout = NETWORK_READ_TIMEOUT_MS
                connect()
            }
            connection.inputStream.use { BitmapFactory.decodeStream(it) }
        } catch (_: Exception) {
            null
        } finally {
            connection?.disconnect()
        }
    }
}
