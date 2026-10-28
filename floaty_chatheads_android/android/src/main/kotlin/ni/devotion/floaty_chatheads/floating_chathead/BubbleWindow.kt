package ni.devotion.floaty_chatheads.floating_chathead

import android.annotation.SuppressLint
import android.graphics.Canvas
import android.graphics.PixelFormat
import android.graphics.Rect
import android.os.Build
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import ni.devotion.floaty_chatheads.services.FloatyContentJobService

/**
 * Small touchable window that draws the collapsed bubble stack and
 * receives its touches.
 *
 * Android 12 and later clamp an untouchable overlay window to 80 percent
 * opacity. The full-screen [ChatHeads] window has to stay untouchable while
 * collapsed so taps reach the app below, so the collapsed bubbles are drawn
 * here instead: this window is touchable and only as large as the stack,
 * which keeps it fully opaque. [ChatHeads] moves it with the top bubble.
 * Its bounds are excluded from system gestures, so dragging a bubble that
 * sits on a screen edge does not trigger Back.
 */
@SuppressLint("ViewConstructor")
internal class BubbleWindow(private val chatHeads: ChatHeads) : View(chatHeads.context) {
    val params = WindowManager.LayoutParams(
        ChatHead.WIDTH,
        ChatHead.HEIGHT,
        WindowManagerHelper.getLayoutFlag(),
        WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED or
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
            WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
        PixelFormat.TRANSLUCENT,
    ).apply { gravity = Gravity.START or Gravity.TOP }

    init {
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    /** Moves and resizes the window onto the stack led by [top] and redraws it. */
    fun follow(top: ChatHead, count: Int, onRight: Boolean) {
        val spread = (count - 1).coerceAtLeast(0) * ChatHeads.CHAT_HEAD_PADDING
        val x = top.x.toInt() - if (onRight) 0 else spread
        val y = top.y.toInt()
        val width = ChatHead.WIDTH + spread
        if (x != params.x || y != params.y || width != params.width) {
            params.x = x
            params.y = y
            params.width = width
            apply()
        }
        invalidate()
    }

    /** Pushes [params] to the window manager. */
    fun apply() {
        if (parent == null) return
        FloatyContentJobService.instance?.windowManager?.updateViewLayout(this, params)
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        super.onLayout(changed, left, top, right, bottom)
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return
        systemGestureExclusionRects = listOf(Rect(0, 0, width, height))
    }

    override fun onDraw(canvas: Canvas) {
        if (chatHeads.toggled) return
        val heads = chatHeads.chatHeads
        val count = heads.size
        val top = chatHeads.topChatHead ?: return
        val padding = ChatHeads.CHAT_HEAD_PADDING
        heads.forEachIndexed { index, head ->
            if (head !== top) drawHead(canvas, head, stackX(index, count, padding))
        }
        drawHead(canvas, top, stackX(count - 1, count, padding))
    }

    private fun stackX(index: Int, count: Int, padding: Int): Float {
        val depth = count - 1 - index
        if (chatHeads.isOnRight) return (depth * padding).toFloat()
        return ((count - 1 - depth) * padding).toFloat()
    }

    private fun drawHead(canvas: Canvas, head: ChatHead, left: Float) {
        if (head.visibility != VISIBLE || head.alpha <= 0f) return
        val w = ChatHead.WIDTH.toFloat()
        val h = ChatHead.HEIGHT.toFloat()
        val saved = canvas.save()
        canvas.translate(left, 0f)
        canvas.clipRect(0f, 0f, w, h)
        canvas.scale(head.scaleX, head.scaleY, w / 2f, h / 2f)
        if (head.alpha < 1f) {
            canvas.saveLayerAlpha(0f, 0f, w, h, (head.alpha * 255).toInt())
        }
        head.drawBubble(canvas)
        canvas.restoreToCount(saved)
    }
}
