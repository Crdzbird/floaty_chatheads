package ni.devotion.floaty_chatheads.floating_chathead

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.os.Build
import android.view.Choreographer
import android.view.View
import android.widget.FrameLayout

/**
 * Transparent debug overlay drawn on top of the ChatHeads FrameLayout.
 *
 * When `OverlayConfig.debugMode == true`, this view renders:
 * - Translucent colored bounds around each ChatHead, content panel, and close target
 * - Position/size labels at each view
 * - Spring velocity HUD for the top chathead
 * - Live FPS counter
 */
class DebugOverlayView(private val chatHeads: ChatHeads) : View(chatHeads.context) {

    private val boundsPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeWidth = 3f
    }

    private val labelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        textSize = 24f
        setShadowLayer(2f, 1f, 1f, Color.BLACK)
    }

    private val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.argb(180, 0, 0, 0)
        style = Paint.Style.FILL
    }

    // ── FPS tracking ───────────────────────────────────────────────
    private var frameCount = 0
    private var lastFpsTime = System.nanoTime()
    private var currentFps = 0

    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            frameCount++
            val elapsed = frameTimeNanos - lastFpsTime
            if (elapsed >= 1_000_000_000L) { // 1 second
                currentFps = frameCount
                frameCount = 0
                lastFpsTime = frameTimeNanos
            }
            invalidate()
            Choreographer.getInstance().postFrameCallback(this)
        }
    }

    init {
        // High z-order so it's always on top
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            z = 200f
        }
        // Don't intercept touches
        isClickable = false
        isFocusable = false
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO

        val lp = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT,
        )
        chatHeads.addView(this, lp)

        // Start frame callback for FPS measurement
        Choreographer.getInstance().postFrameCallback(frameCallback)
    }

    fun stop() {
        Choreographer.getInstance().removeFrameCallback(frameCallback)
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        var yOffset = 40f

        // ── FPS counter ────────────────────────────────────────────
        val fpsText = "FPS: $currentFps"
        canvas.drawRect(8f, yOffset - 24f, 8f + labelPaint.measureText(fpsText) + 16f, yOffset + 8f, bgPaint)
        canvas.drawText(fpsText, 16f, yOffset, labelPaint)
        yOffset += 36f

        // ── Spring HUD ─────────────────────────────────────────────
        chatHeads.topChatHead?.let { top ->
            val springInfo = "Spring X: vel=%.0f end=%.0f | Y: vel=%.0f end=%.0f".format(
                top.springX.velocity,
                top.springX.endValue,
                top.springY.velocity,
                top.springY.endValue,
            )
            canvas.drawRect(8f, yOffset - 24f, 8f + labelPaint.measureText(springInfo) + 16f, yOffset + 8f, bgPaint)
            canvas.drawText(springInfo, 16f, yOffset, labelPaint)
            yOffset += 36f

            val stateInfo = "toggled=${chatHeads.toggled} captured=${chatHeads.captured} heads=${chatHeads.chatHeads.size}"
            canvas.drawRect(8f, yOffset - 24f, 8f + labelPaint.measureText(stateInfo) + 16f, yOffset + 8f, bgPaint)
            canvas.drawText(stateInfo, 16f, yOffset, labelPaint)
            yOffset += 36f
        }

        // ── Bounds: ChatHeads ──────────────────────────────────────
        boundsPaint.color = Color.argb(128, 0, 255, 0) // Green
        for (chatHead in chatHeads.chatHeads) {
            if (chatHead.visibility == VISIBLE) {
                canvas.drawRect(
                    chatHead.x, chatHead.y,
                    chatHead.x + chatHead.width, chatHead.y + chatHead.height,
                    boundsPaint,
                )
                val label = "${chatHead.id} (%.0f, %.0f) %dx%d".format(
                    chatHead.x, chatHead.y, chatHead.width, chatHead.height,
                )
                canvas.drawText(label, chatHead.x, chatHead.y - 4f, labelPaint)
            }
        }

        // ── Bounds: Content panel ──────────────────────────────────
        val content = chatHeads.content
        if (content.visibility == VISIBLE) {
            boundsPaint.color = Color.argb(128, 0, 128, 255) // Blue
            canvas.drawRect(
                content.x, content.y,
                content.x + content.width, content.y + content.height,
                boundsPaint,
            )
            val contentLabel = "content (%.0f, %.0f) %dx%d scale=%.2f".format(
                content.x, content.y, content.width, content.height, content.scaleX,
            )
            canvas.drawText(contentLabel, content.x, content.y - 4f, labelPaint)
        }
    }
}
