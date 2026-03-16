package ni.devotion.floaty_chatheads

import android.content.Context
import android.graphics.Color
import android.view.Gravity
import android.view.View
import android.view.accessibility.AccessibilityEvent
import android.widget.FrameLayout
import com.facebook.rebound.SimpleSpringListener
import com.facebook.rebound.Spring
import com.facebook.rebound.SpringSystem
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import ni.devotion.floaty_chatheads.floating_chathead.SpringConfigs
import ni.devotion.floaty_chatheads.utils.Managment

class FlutterContentPanel(context: Context) : FrameLayout(context) {
    private val springSystem = SpringSystem.create()
    private val scaleSpring = springSystem.createSpring()
    private var flutterView: FlutterView? = null

    // Target dimensions in pixels.  Stored here so they survive the
    // GONE→VISIBLE transition and can be re-applied in showContent().
    private var targetWidthPx: Int? = null
    private var targetHeightPx: Int? = null

    init {
        // Start completely hidden — not measured, not laid out, not rendered.
        visibility = View.GONE
        scaleSpring.springConfig = SpringConfigs.CONTENT_SCALE
        scaleSpring.currentValue = 0.0
        scaleSpring.addListener(object : SimpleSpringListener() {
            override fun onSpringUpdate(spring: Spring) {
                val value = spring.currentValue.toFloat()
                scaleX = value
                scaleY = value
            }

            override fun onSpringAtRest(spring: Spring) {
                // When the hide animation finishes (scale reaches 0), go GONE
                // so the FlutterView stops participating in layout/rendering.
                if (spring.currentValue < 0.01) {
                    visibility = View.GONE
                }
            }
        })

        // ── Accessibility ──────────────────────────────────────────────
        contentDescription = "Chat content panel"
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
    }

    /**
     * Store and immediately apply target dimensions (in px).
     * The values are re-applied in [showContent] to guarantee they
     * survive the GONE→VISIBLE layout transition.
     */
    fun setContentSize(widthPx: Int, heightPx: Int) {
        Managment.logD("setContentSize() widthPx=$widthPx, heightPx=$heightPx")
        targetWidthPx = widthPx
        targetHeightPx = heightPx
        applyTargetSize()
    }

    private fun applyTargetSize() {
        val w = targetWidthPx ?: return
        val h = targetHeightPx ?: return
        layoutParams = LayoutParams(w, h).apply {
            gravity = Gravity.CENTER
        }
        Managment.logD("applyTargetSize() w=$w, h=$h")
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val tw = targetWidthPx
        val th = targetHeightPx
        if (tw != null && tw > 0 && th != null && th > 0) {
            // Force exact target dimensions regardless of what the parent suggests.
            val wSpec = MeasureSpec.makeMeasureSpec(tw, MeasureSpec.EXACTLY)
            val hSpec = MeasureSpec.makeMeasureSpec(th, MeasureSpec.EXACTLY)
            Managment.logD("onMeasure() FORCING tw=$tw, th=$th (incoming: ${MeasureSpec.getSize(widthMeasureSpec)}x${MeasureSpec.getSize(heightMeasureSpec)})")
            super.onMeasure(wSpec, hSpec)
        } else {
            super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        }
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        Managment.logD("onSizeChanged() ${oldw}x${oldh} -> ${w}x${h} (target=${targetWidthPx}x${targetHeightPx})")
    }

    fun attachEngine(engine: FlutterEngine) {
        Managment.logD("attachEngine() called. visibility=$visibility, childCount=$childCount")
        val textureView = FlutterTextureView(context)
        flutterView = FlutterView(context, textureView).apply {
            attachToFlutterEngine(engine)
            isFocusable = true
            isFocusableInTouchMode = true
            setBackgroundColor(Color.TRANSPARENT)
        }
        addView(
            flutterView,
            LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT),
        )
        engine.lifecycleChannel.appIsResumed()
        Managment.logD("attachEngine() done. childCount=$childCount")
    }

    fun detachEngine() {
        flutterView?.detachFromFlutterEngine()
        removeAllViews()
        flutterView = null
    }

    fun showContent() {
        // Re-apply target dimensions before becoming visible so they
        // survive the GONE → VISIBLE layout transition.
        applyTargetSize()
        Managment.logD("showContent() lp.w=${layoutParams?.width}, lp.h=${layoutParams?.height}, targetW=$targetWidthPx, targetH=$targetHeightPx")
        // Make the panel visible and start the scale-up animation.
        visibility = View.VISIBLE
        // Force the parent to re-measure this view with the correct params.
        forceLayout()
        requestLayout()
        scaleSpring.endValue = 1.0
        // Accessibility: announce focus
        sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_FOCUSED)
        // Post a verification check after the layout pass completes.
        post {
            Managment.logD("showContent() POST-LAYOUT: measuredW=$measuredWidth, measuredH=$measuredHeight, w=$width, h=$height, lp.w=${layoutParams?.width}, lp.h=${layoutParams?.height}")
            val tw = targetWidthPx
            val th = targetHeightPx
            if (tw != null && tw > 0 && th != null && th > 0) {
                if (measuredWidth != tw || measuredHeight != th) {
                    Managment.logW("DIMENSION MISMATCH! Forcing re-measure: target=${tw}x${th}, actual=${measuredWidth}x${measuredHeight}")
                    // Emergency: force exact dimensions directly.
                    val wSpec = MeasureSpec.makeMeasureSpec(tw, MeasureSpec.EXACTLY)
                    val hSpec = MeasureSpec.makeMeasureSpec(th, MeasureSpec.EXACTLY)
                    measure(wSpec, hSpec)
                    layout(left, top, left + tw, top + th)
                }
            }
        }
    }

    fun hideContent() {
        // Start scale-down animation; onSpringAtRest will set GONE.
        scaleSpring.endValue = 0.0
        // Accessibility: announce hidden
        announceForAccessibility("Content panel hidden")
    }
}
