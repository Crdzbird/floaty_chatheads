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
import ni.devotion.floaty_chatheads.utils.OverlayConfig

class FlutterContentPanel(context: Context) : FrameLayout(context) {
    private val springSystem = SpringSystem.create()
    private val scaleSpring = springSystem.createSpring()
    private var flutterView: FlutterView? = null

    private var targetWidthPx: Int? = null
    private var targetHeightPx: Int? = null

    init {
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
                if (spring.currentValue < 0.01) {
                    visibility = View.GONE
                }
            }
        })

        contentDescription = "Chat content panel"
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
    }

    /**
     * Store and immediately apply target dimensions (in px).
     * The values are re-applied in [showContent] to guarantee they
     * survive the GONE to VISIBLE layout transition.
     */
    fun setContentSize(widthPx: Int, heightPx: Int) {
        OverlayConfig.logD("setContentSize() widthPx=$widthPx, heightPx=$heightPx")
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
        OverlayConfig.logD("applyTargetSize() w=$w, h=$h")
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val tw = targetWidthPx
        val th = targetHeightPx
        if (tw != null && tw > 0 && th != null && th > 0) {
            val wSpec = MeasureSpec.makeMeasureSpec(tw, MeasureSpec.EXACTLY)
            val hSpec = MeasureSpec.makeMeasureSpec(th, MeasureSpec.EXACTLY)
            OverlayConfig.logD("onMeasure() FORCING tw=$tw, th=$th (incoming: ${MeasureSpec.getSize(widthMeasureSpec)}x${MeasureSpec.getSize(heightMeasureSpec)})")
            super.onMeasure(wSpec, hSpec)
        } else {
            super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        }
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        OverlayConfig.logD("onSizeChanged() ${oldw}x${oldh} -> ${w}x${h} (target=${targetWidthPx}x${targetHeightPx})")
    }

    fun attachEngine(engine: FlutterEngine) {
        OverlayConfig.logD("attachEngine() called. visibility=$visibility, childCount=$childCount")
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
        OverlayConfig.logD("attachEngine() done. childCount=$childCount")
    }

    fun detachEngine() {
        flutterView?.detachFromFlutterEngine()
        removeAllViews()
        flutterView = null
    }

    fun showContent() {
        applyTargetSize()
        OverlayConfig.logD("showContent() lp.w=${layoutParams?.width}, lp.h=${layoutParams?.height}, targetW=$targetWidthPx, targetH=$targetHeightPx")
        visibility = View.VISIBLE
        forceLayout()
        requestLayout()
        scaleSpring.endValue = 1.0
        sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_FOCUSED)
        post {
            OverlayConfig.logD("showContent() POST-LAYOUT: measuredW=$measuredWidth, measuredH=$measuredHeight, w=$width, h=$height, lp.w=${layoutParams?.width}, lp.h=${layoutParams?.height}")
            val tw = targetWidthPx
            val th = targetHeightPx
            if (tw != null && tw > 0 && th != null && th > 0) {
                if (measuredWidth != tw || measuredHeight != th) {
                    OverlayConfig.logW("DIMENSION MISMATCH! Forcing re-measure: target=${tw}x${th}, actual=${measuredWidth}x${measuredHeight}")
                    val wSpec = MeasureSpec.makeMeasureSpec(tw, MeasureSpec.EXACTLY)
                    val hSpec = MeasureSpec.makeMeasureSpec(th, MeasureSpec.EXACTLY)
                    measure(wSpec, hSpec)
                    layout(left, top, left + tw, top + th)
                }
            }
        }
    }

    fun hideContent() {
        scaleSpring.endValue = 0.0
        announceForAccessibility("Content panel hidden")
    }
}
