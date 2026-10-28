package ni.devotion.floaty_chatheads.services

import android.graphics.Bitmap
import android.graphics.BitmapShader
import android.graphics.BlurMaskFilter
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.Shader
import ni.devotion.floaty_chatheads.floating_chathead.ChatHeads
import ni.devotion.floaty_chatheads.utils.OverlayConfig
import java.nio.ByteBuffer

/** One raw RGBA icon frame received from Dart. */
internal class IconFrame(val rgba: ByteArray, val width: Int, val height: Int)

/**
 * Turns raw RGBA icon frames into the circular, shadowed bubble bitmap
 * without per-frame allocations.
 *
 * The shadow silhouette is identical for every frame, so it is blurred
 * once. Frames rotate through [BUFFER_COUNT] output bitmaps, so the bitmap
 * currently on screen is never written. The renderer owns its bitmaps:
 * views must not recycle them. Not thread-safe; the plugin renders one
 * frame at a time.
 */
internal class IconFrameRenderer {
    companion object {
        private const val BUFFER_COUNT = 3
        private const val SHADOW_RADIUS = 6f
        private const val SHADOW_DROP = 4f
        private const val PAD_X = 10
        private const val PAD_Y = 20
        private const val MAX_DIMENSION = 4096L

        /** True when [byteCount] matches a [width] x [height] RGBA frame. */
        fun isValidFrame(width: Long, height: Long, byteCount: Int): Boolean =
            width in 1..MAX_DIMENSION &&
                height in 1..MAX_DIMENSION &&
                byteCount.toLong() == width * height * 4L
    }

    private val size = ChatHeads.CHAT_HEAD_SIZE
    private val left = ((size + PAD_X) / 2 - size / 2).toFloat()
    private val top = ((size + PAD_Y) / 2 - size / 2).toFloat()
    private val radius = size / 2f
    private val outputs = Array(BUFFER_COUNT) {
        Bitmap.createBitmap(size + PAD_X, size + PAD_Y, Bitmap.Config.ARGB_8888)
    }
    private val canvas = Canvas()
    private val matrix = Matrix()
    private val shadowOffset = IntArray(2)
    private val shadow = buildShadow()
    private val shadowPaint = Paint().apply { color = OverlayConfig.bubbleShadowColor }
    private val iconPaint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
    private var input: Bitmap? = null
    private var next = 0

    /** Renders [frame] into the next output buffer and returns it. */
    fun render(frame: IconFrame): Bitmap {
        val source = inputFor(frame.width, frame.height)
        source.copyPixelsFromBuffer(ByteBuffer.wrap(frame.rgba))
        val out = outputs[next]
        next = (next + 1) % BUFFER_COUNT
        out.eraseColor(Color.TRANSPARENT)
        canvas.setBitmap(out)
        canvas.drawBitmap(
            shadow,
            left + shadowOffset[0],
            top + shadowOffset[1] + SHADOW_DROP,
            shadowPaint,
        )
        matrix.setScale(size.toFloat() / frame.width, size.toFloat() / frame.height)
        matrix.postTranslate(left, top)
        iconPaint.shader?.setLocalMatrix(matrix)
        canvas.drawCircle(left + radius, top + radius, radius, iconPaint)
        canvas.setBitmap(null)
        return out
    }

    private fun inputFor(width: Int, height: Int): Bitmap {
        val cached = input
        if (cached != null && cached.width == width && cached.height == height) return cached
        val created = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        input = created
        iconPaint.shader = BitmapShader(created, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP)
        return created
    }

    private fun buildShadow(): Bitmap {
        val silhouette = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        Canvas(silhouette).drawCircle(radius, radius, radius, Paint(Paint.ANTI_ALIAS_FLAG))
        val blur = Paint().apply {
            maskFilter = BlurMaskFilter(SHADOW_RADIUS, BlurMaskFilter.Blur.NORMAL)
        }
        val alpha = silhouette.extractAlpha(blur, shadowOffset)
        silhouette.recycle()
        return alpha
    }
}
