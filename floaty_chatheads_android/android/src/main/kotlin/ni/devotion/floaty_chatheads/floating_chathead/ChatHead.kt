package ni.devotion.floaty_chatheads.floating_chathead

import android.graphics.*
import android.graphics.BitmapFactory.*
import android.view.*
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import androidx.core.view.ViewCompat
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat
import com.facebook.rebound.*
import ni.devotion.floaty_chatheads.R
import ni.devotion.floaty_chatheads.utils.ImageHelper
import ni.devotion.floaty_chatheads.utils.Managment
import kotlin.math.hypot
import kotlin.math.pow

class ChatHead(var chatHeads: ChatHeads, val id: String = "default", var iconBitmap: android.graphics.Bitmap? = null): View(chatHeads.context), View.OnTouchListener, SpringListener {
    var isTop: Boolean = false
    var isActive: Boolean = false

    /** Badge count – 0 means hidden. */
    var badgeCount: Int = 0
        set(value) {
            field = value
            updateAccessibilityDescription()
            invalidate()
        }

    private val badgePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Managment.badgeColor
        style = Paint.Style.FILL
    }

    private val badgeTextPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Managment.badgeTextColor
        textSize = WindowManagerHelper.dpToPx(10f).toFloat()
        typeface = Typeface.DEFAULT_BOLD
        textAlign = Paint.Align.CENTER
    }

    private val borderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
    }

    var params: WindowManager.LayoutParams = WindowManager.LayoutParams(
        WindowManager.LayoutParams.WRAP_CONTENT,
        WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManagerHelper.getLayoutFlag(),
        0,
        PixelFormat.TRANSLUCENT
    )
    var springSystem = SpringSystem.create()
    var springX = springSystem.createSpring()
    var springY = springSystem.createSpring()
    val paint = Paint()
    private var initialX = 0.0f
    private var initialY = 0.0f
    private var initialTouchX = 0.0f
    private var initialTouchY = 0.0f
    private var moving = false
    override fun onSpringEndStateChange(spring: Spring?) {}

    override fun onSpringAtRest(spring: Spring?) {}

    override fun onSpringActivate(spring: Spring?) {}

    init {
        params.gravity = Gravity.TOP or Gravity.START
        params.x = 0
        params.y = 0
        params.width = ChatHeads.CHAT_HEAD_SIZE + 15
        params.height = ChatHeads.CHAT_HEAD_SIZE + 30
        springX.addListener(object : SimpleSpringListener() {
            override fun onSpringUpdate(spring: Spring) {
                x = spring.currentValue.toFloat()
            }
        })
        springX.springConfig = SpringConfigs.NOT_DRAGGING
        springX.addListener(this)
        springY.addListener(object : SimpleSpringListener() {
            override fun onSpringUpdate(spring: Spring) {
                y = spring.currentValue.toFloat()
            }
        })
        springY.springConfig = SpringConfigs.NOT_DRAGGING
        springY.addListener(this)
        this.setLayerType(LAYER_TYPE_HARDWARE, paint)
        chatHeads.addView(this, params)
        this.setOnTouchListener(this)

        // ── Accessibility ──────────────────────────────────────────────
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        updateAccessibilityDescription()
        ViewCompat.setAccessibilityDelegate(this, object : androidx.core.view.AccessibilityDelegateCompat() {
            override fun onInitializeAccessibilityNodeInfo(host: View, info: AccessibilityNodeInfoCompat) {
                super.onInitializeAccessibilityNodeInfo(host, info)
                info.addAction(
                    AccessibilityNodeInfoCompat.AccessibilityActionCompat(
                        AccessibilityNodeInfoCompat.ACTION_CLICK,
                        if (chatHeads.toggled) "Collapse chat" else "Expand chat"
                    )
                )
                info.addAction(
                    AccessibilityNodeInfoCompat.AccessibilityActionCompat(
                        AccessibilityNodeInfoCompat.ACTION_DISMISS,
                        "Close chat bubble"
                    )
                )
            }
        })
    }

    private fun updateAccessibilityDescription() {
        contentDescription = if (badgeCount > 0) {
            "Chat bubble $id, $badgeCount new messages"
        } else {
            "Chat bubble $id"
        }
    }

    override fun onSpringUpdate(spring: Spring) {
        if (spring !== this.springX && spring !== this.springY) return
        val totalVelocity = hypot(springX.velocity, springY.velocity).toInt()
        chatHeads.onSpringUpdate(this, spring, totalVelocity)
    }

    override fun onDraw(canvas: Canvas) {
        val icon = iconBitmap ?: Managment.floatingIcon
        if (icon != null) {
            canvas.drawBitmap(ImageHelper.addShadow(ImageHelper.getCircularBitmap(icon)), 0f, 0f, paint)
        } else {
            canvas.drawBitmap(ImageHelper.addShadow(ImageHelper.getCircularBitmap(decodeResource(Managment.globalContext!!.resources, R.drawable.bot))), 0f, 0f, paint)
        }

        // Draw optional border ring
        val borderColor = Managment.bubbleBorderColor
        val borderWidth = Managment.bubbleBorderWidth
        if (borderColor != null && borderWidth > 0f) {
            borderPaint.color = borderColor
            borderPaint.strokeWidth = WindowManagerHelper.dpToPx(borderWidth).toFloat()
            val shadowBitmap = ImageHelper.addShadow(ImageHelper.getCircularBitmap(
                icon ?: decodeResource(Managment.globalContext!!.resources, R.drawable.bot)
            ))
            val cx = shadowBitmap.width / 2f
            val cy = shadowBitmap.height / 2f
            val radius = ChatHeads.CHAT_HEAD_SIZE / 2f
            canvas.drawCircle(cx, cy, radius, borderPaint)
        }

        // Draw badge
        if (badgeCount > 0) {
            // Update badge paint colors from theme
            badgePaint.color = Managment.badgeColor
            badgeTextPaint.color = Managment.badgeTextColor

            val badgeRadius = WindowManagerHelper.dpToPx(9f).toFloat()
            val badgeText = if (badgeCount > 99) "99+" else badgeCount.toString()
            // Position at top-right of the circular icon
            val cx = width - badgeRadius - WindowManagerHelper.dpToPx(4f)
            val cy = badgeRadius + WindowManagerHelper.dpToPx(2f)
            // Draw pill for 2+ digit numbers
            val textWidth = badgeTextPaint.measureText(badgeText)
            val pillHalfWidth = (textWidth / 2 + WindowManagerHelper.dpToPx(4f)).coerceAtLeast(badgeRadius)
            canvas.drawRoundRect(
                cx - pillHalfWidth, cy - badgeRadius,
                cx + pillHalfWidth, cy + badgeRadius,
                badgeRadius, badgeRadius, badgePaint
            )
            // Draw text centered vertically
            val textBaseline = cy - (badgeTextPaint.ascent() + badgeTextPaint.descent()) / 2
            canvas.drawText(badgeText, cx, textBaseline, badgeTextPaint)
        }
    }

    override fun onTouch(v: View?, event: MotionEvent?): Boolean {
        val currentChatHead = chatHeads.chatHeads.find { it == v }!!
        val metrics = WindowManagerHelper.getScreenSize()
        when (event!!.action) {
            MotionEvent.ACTION_DOWN -> {
                initialX = x
                initialY = y
                initialTouchX = event.rawX
                initialTouchY = event.rawY
                scaleX = 0.9f
                scaleY = 0.9f
            }
            MotionEvent.ACTION_UP -> {
                if (!moving) {
                    if (currentChatHead.isActive) {
                        chatHeads.collapse()
                    } else {
                        val selectedChatHead = chatHeads.chatHeads.find { it.isActive }
                        selectedChatHead?.isActive = false
                        currentChatHead.isActive = true
                        chatHeads.changeContent()
                    }
                } else {
                    springX.endValue = metrics.widthPixels - width - (chatHeads.chatHeads.size - 1 - chatHeads.chatHeads.indexOf(this)) * (width + ChatHeads.CHAT_HEAD_EXPANDED_PADDING).toDouble()
                    springY.endValue = ChatHeads.CHAT_HEAD_EXPANDED_MARGIN_TOP.toDouble()
                    if (isActive) {
                        chatHeads.content.showContent()
                    }
                }
                scaleX = 1f
                scaleY = 1f
                moving = false
            }
            MotionEvent.ACTION_MOVE -> {
                if (ChatHeads.distance(initialTouchX, event.rawX, initialTouchY, event.rawY) > ChatHeads.CHAT_HEAD_DRAG_TOLERANCE.pow(2) && !moving) {
                    moving = true
                    if (isActive) {
                        chatHeads.content.hideContent()
                    }
                }
                if (moving) {
                    springX.currentValue = initialX + (event.rawX - initialTouchX).toDouble()
                    springY.currentValue = initialY + (event.rawY - initialTouchY).toDouble()
                }
            }
        }
        return true
    }
}
