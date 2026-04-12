package ni.devotion.floaty_chatheads.floating_chathead

import android.graphics.*
import android.os.Build
import android.view.*
import android.widget.FrameLayout
import android.widget.RelativeLayout
import androidx.core.content.ContextCompat
import com.facebook.rebound.*
import ni.devotion.floaty_chatheads.R
import ni.devotion.floaty_chatheads.utils.OverlayConfig

class Close(var chatHeads: ChatHeads): View(chatHeads.context) {
    private var params = WindowManager.LayoutParams(
        ChatHeads.CLOSE_SIZE + ChatHeads.CLOSE_ADDITIONAL_SIZE,
        ChatHeads.CLOSE_SIZE + ChatHeads.CLOSE_ADDITIONAL_SIZE,
            WindowManagerHelper.getLayoutFlag(),
        WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
        PixelFormat.TRANSLUCENT
    )

    private var gradientParams = FrameLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, WindowManagerHelper.dpToPx(150f))
    var springSystem = SpringSystem.create()
    var springY = springSystem.createSpring()
    var springX = springSystem.createSpring()
    var springAlpha = springSystem.createSpring()
    var springScale = springSystem.createSpring()
    val paint = Paint()
    private val closePaint = Paint()
    val gradient = FrameLayout(context)

    /** Unscaled source bitmap for the close background (decoded once). */
    private val bgSourceBitmap: Bitmap = OverlayConfig.backgroundCloseIcon
        ?: BitmapFactory.decodeResource(context.resources, R.drawable.close_bg)

    private var bitmapBg: Bitmap? = null
    private var bitmapClose: Bitmap? = null

    fun hide() {
        val metrics = WindowManagerHelper.getScreenSize()
        springY.endValue = metrics.heightPixels.toDouble() + height
        springX.endValue = metrics.widthPixels.toDouble() / 2 - width / 2
        springAlpha.endValue = 0.0
    }

    fun show() {
        visibility = View.VISIBLE
        springAlpha.endValue = 1.0
        // Accessibility announcement
        announceForAccessibility("Close target visible")
    }

    private fun onPositionUpdate() {
        if (chatHeads.captured) {
            chatHeads.topChatHead!!.springX.endValue = springX.currentValue + width / 2 - chatHeads.topChatHead!!.width / 2 + 2
            chatHeads.topChatHead!!.springY.endValue = springY.currentValue + height / 2 - chatHeads.topChatHead!!.height / 2 + 2
        }
    }

    init {
        bitmapBg = Bitmap.createScaledBitmap(bgSourceBitmap, ChatHeads.CLOSE_SIZE, ChatHeads.CLOSE_SIZE, false)

        // Widget-rendered close icons fill the close target; asset icons
        // stay at the small 28 dp default so they sit on top of the bg.
        val closeIconSize = if (OverlayConfig.closeIconIsWidget) {
            ChatHeads.CLOSE_SIZE
        } else {
            WindowManagerHelper.dpToPx(28f)
        }
        val closeSource = OverlayConfig.closeIcon
        bitmapClose = if (closeSource != null) {
            Bitmap.createScaledBitmap(closeSource, closeIconSize, closeIconSize, false)
        } else {
            Bitmap.createScaledBitmap(BitmapFactory.decodeResource(context.resources, R.drawable.close), WindowManagerHelper.dpToPx(28f), WindowManagerHelper.dpToPx(28f), false)
        }

        // Apply close tint color from theme
        OverlayConfig.closeTintColor?.let { tint ->
            closePaint.colorFilter = PorterDuffColorFilter(tint, PorterDuff.Mode.SRC_IN)
        }

        this.setLayerType(View.LAYER_TYPE_HARDWARE, paint)
        visibility = View.INVISIBLE
        hide()
        springY.addListener(object : SimpleSpringListener() {
            override fun onSpringUpdate(spring: Spring) {
                y = spring.currentValue.toFloat()
                if (chatHeads.captured && chatHeads.wasMoving) {
                    chatHeads.topChatHead!!.springY.currentValue = spring.currentValue
                }
                onPositionUpdate()
            }
        })
        springX.addListener(object : SimpleSpringListener() {
            override fun onSpringUpdate(spring: Spring) {
                x = spring.currentValue.toFloat()
                onPositionUpdate()
            }
        })
        springScale.addListener(object : SimpleSpringListener() {
            override fun onSpringUpdate(spring: Spring) {
                val animatedSize = (spring.currentValue + ChatHeads.CLOSE_SIZE).toInt()
                bitmapBg = Bitmap.createScaledBitmap(bgSourceBitmap, animatedSize, animatedSize, false)
                invalidate()
            }
        })
        springAlpha.addListener(object : SimpleSpringListener() {
            override fun onSpringUpdate(spring: Spring) {
                gradient.alpha = spring.currentValue.toFloat()
            }
        })
        springScale.springConfig = SpringConfigs.CLOSE_SCALE
        springY.springConfig = SpringConfigs.CLOSE_Y
        params.gravity = Gravity.START or Gravity.TOP
        gradientParams.gravity = Gravity.BOTTOM
        gradient.background = ContextCompat.getDrawable(context, R.drawable.gradient_bg)
        springAlpha.currentValue = 0.0
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) z = 100f

        // ── Accessibility ──────────────────────────────────────────────
        contentDescription = "Close target. Drop here to dismiss."
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
            accessibilityLiveRegion = ACCESSIBILITY_LIVE_REGION_POLITE
        }

        chatHeads.addView(this, params)
        chatHeads.addView(gradient, gradientParams)
    }

    override fun onDraw(canvas: Canvas) {
        bitmapBg?.let {
            canvas.drawBitmap(it, width / 2 - it.width.toFloat() / 2, height / 2 - it.height.toFloat() / 2, paint)
        }
        bitmapClose?.let {
            // Use closePaint if a tint is set, otherwise default paint
            val drawPaint = if (OverlayConfig.closeTintColor != null) closePaint else paint
            canvas.drawBitmap(it, width / 2 - it.width.toFloat() / 2, height / 2 - it.height.toFloat() / 2, drawPaint)
        }
    }
}
