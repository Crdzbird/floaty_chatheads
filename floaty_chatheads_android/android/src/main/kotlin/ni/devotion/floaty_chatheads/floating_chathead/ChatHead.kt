package ni.devotion.floaty_chatheads.floating_chathead

import android.graphics.*
import android.graphics.BitmapFactory.*
import android.view.*
import androidx.core.view.ViewCompat
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat
import com.facebook.rebound.*
import ni.devotion.floaty_chatheads.R
import ni.devotion.floaty_chatheads.utils.ImageHelper
import ni.devotion.floaty_chatheads.utils.OverlayConfig
import kotlin.math.hypot
import kotlin.math.pow

/**
 * A single chathead bubble.
 *
 * ## Gesture role vs [ChatHeads]
 *
 * Touch handling for the overlay is **split deliberately** between two
 * classes — they are complementary, not duplicates:
 *
 * - [ChatHeads.onTouch] is wired through the `motionTracker` proxy and
 *   handles the **collapsed** state: dragging the single bubble around
 *   the screen, velocity throwing, drag-to-close capture, and
 *   snap-to-edge resolution.
 * - [onTouch] (this class) handles the **expanded multi-chathead row**:
 *   tapping an individual bubble to switch active selection, collapsing
 *   when the active bubble is tapped again, and pulling a single bubble
 *   out of the row mid-drag.
 *
 * The two paths cannot fire simultaneously because the underlying
 * `WindowManager` window flags toggle `FLAG_NOT_TOUCHABLE` on the
 * inactive one when expand/collapse transitions occur.
 */
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
        color = OverlayConfig.badgeColor
        style = Paint.Style.FILL
    }

    private val badgeTextPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = OverlayConfig.badgeTextColor
        textSize = WindowManagerHelper.dpToPx(10f).toFloat()
        typeface = Typeface.DEFAULT_BOLD
        textAlign = Paint.Align.CENTER
    }

    private val borderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
    }

    /** Cached circular+shadow bitmap, recomputed only when icon source changes. */
    private var processedIcon: Bitmap? = null
    /** The raw source bitmap that [processedIcon] was built from. */
    private var processedIconSource: Bitmap? = null
    /** True when [processedIcon] was built here, so this view may recycle it. */
    private var processedIconOwned = false

    /** Built-in bubble icon, decoded once at its native size. */
    private val defaultIcon: Bitmap by lazy {
        decodeResource(context.resources, R.drawable.bot, Options().apply { inScaled = false })
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

    /** Shows a circular, shadowed frame produced by the icon renderer.
     *  The renderer owns and reuses [processed], so it is never recycled
     *  here. Called on the main thread. */
    fun updateIcon(processed: Bitmap) {
        val previous = processedIcon
        val previousOwned = processedIconOwned
        processedIcon = processed
        processedIconSource = processed
        processedIconOwned = false
        iconBitmap = processed
        invalidate()
        if (previousOwned && previous !== processed) previous?.takeIf { !it.isRecycled }?.recycle()
    }

    /** Returns a circular+shadow bitmap, cached to avoid allocations in onDraw. */
    private fun getProcessedIcon(): Bitmap {
        val source = iconBitmap ?: OverlayConfig.floatingIcon ?: defaultIcon
        val cached = processedIcon
        if (cached != null && source === processedIconSource) return cached
        val built = ImageHelper.addShadow(ImageHelper.getCircularBitmap(source))
        if (processedIconOwned) cached?.takeIf { !it.isRecycled }?.recycle()
        processedIcon = built
        processedIconSource = source
        processedIconOwned = true
        return built
    }

    override fun onDraw(canvas: Canvas) {
        val processed = getProcessedIcon()
        canvas.drawBitmap(processed, 0f, 0f, paint)

        // Draw optional border ring
        val borderColor = OverlayConfig.bubbleBorderColor
        val borderWidth = OverlayConfig.bubbleBorderWidth
        if (borderColor != null && borderWidth > 0f) {
            borderPaint.color = borderColor
            borderPaint.strokeWidth = WindowManagerHelper.dpToPx(borderWidth).toFloat()
            val cx = processed.width / 2f
            val cy = processed.height / 2f
            val radius = ChatHeads.CHAT_HEAD_SIZE / 2f
            canvas.drawCircle(cx, cy, radius, borderPaint)
        }

        // Draw badge
        if (badgeCount > 0) {
            // Update badge paint colors from theme
            badgePaint.color = OverlayConfig.badgeColor
            badgeTextPaint.color = OverlayConfig.badgeTextColor

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
                    springX.endValue = chatHeads.expandedRowX(chatHeads.chatHeads.indexOf(this), width)
                    springY.endValue = chatHeads.expandedRowY()
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
