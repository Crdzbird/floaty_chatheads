package ni.devotion.floaty_chatheads

import android.content.Context
import android.graphics.Color
import android.util.Log
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

class FlutterContentPanel(context: Context) : FrameLayout(context) {
    private val springSystem = SpringSystem.create()
    private val scaleSpring = springSystem.createSpring()
    private var flutterView: FlutterView? = null

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

    fun attachEngine(engine: FlutterEngine) {
        Log.d("FloatyDebug", "attachEngine() called. visibility=$visibility, childCount=$childCount")
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
        Log.d("FloatyDebug", "attachEngine() done. childCount=$childCount, flutterView=$flutterView")
    }

    fun detachEngine() {
        flutterView?.detachFromFlutterEngine()
        removeAllViews()
        flutterView = null
    }

    fun showContent() {
        // Make the panel visible and start the scale-up animation.
        Log.d("FloatyDebug", "showContent() called. childCount=$childCount, w=$width, h=$height, lp.w=${layoutParams?.width}, lp.h=${layoutParams?.height}, visibility=$visibility")
        visibility = View.VISIBLE
        scaleSpring.endValue = 1.0
        // Accessibility: announce focus
        sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_FOCUSED)
        Log.d("FloatyDebug", "showContent() done. visibility=$visibility, scaleX=$scaleX, scaleY=$scaleY")
    }

    fun hideContent() {
        // Start scale-down animation; onSpringAtRest will set GONE.
        scaleSpring.endValue = 0.0
        // Accessibility: announce hidden
        announceForAccessibility("Content panel hidden")
    }
}
