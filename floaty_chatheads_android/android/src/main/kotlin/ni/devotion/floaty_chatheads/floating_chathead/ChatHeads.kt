package ni.devotion.floaty_chatheads.floating_chathead

import android.annotation.SuppressLint
import android.content.Context
import android.content.SharedPreferences
import android.graphics.PixelFormat
import android.os.Handler
import android.os.Looper
import android.view.*
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.view.VelocityTracker
import com.facebook.rebound.Spring
import com.facebook.rebound.SimpleSpringListener
import com.facebook.rebound.SpringChain
import java.util.*
import kotlin.math.*
import android.app.ActivityManager
import ni.devotion.floaty_chatheads.FlutterContentPanel
import ni.devotion.floaty_chatheads.services.FloatyContentJobService
import ni.devotion.floaty_chatheads.utils.EntranceAnimation
import ni.devotion.floaty_chatheads.utils.OverlayConfig
import ni.devotion.floaty_chatheads.utils.SnapEdge


class ChatHeads(context: Context) : View.OnTouchListener, FrameLayout(context) {
    companion object {
        val CHAT_HEAD_OUT_OF_SCREEN_X: Int = WindowManagerHelper.dpToPx(10f)
        val CHAT_HEAD_SIZE: Int = WindowManagerHelper.dpToPx(64f)
        val CHAT_HEAD_PADDING: Int = WindowManagerHelper.dpToPx(6f)
        val CHAT_HEAD_EXPANDED_PADDING: Int = WindowManagerHelper.dpToPx(4f)
        val CHAT_HEAD_EXPANDED_MARGIN_TOP: Float = WindowManagerHelper.dpToPx(4f).toFloat()
        val CLOSE_SIZE = WindowManagerHelper.dpToPx(64f)
        val CLOSE_CAPTURE_DISTANCE = WindowManagerHelper.dpToPx(100f)
        val CLOSE_ADDITIONAL_SIZE = WindowManagerHelper.dpToPx(24f)
        const val CHAT_HEAD_DRAG_TOLERANCE: Float = 20f
        private const val CLOSE_DELAY_MS = 200L
        private const val HIDE_DELAY_MS = 300L
        private const val EXPAND_CONTENT_DELAY_MS = 200L
        private const val PREFS_NAME = "floaty_chatheads_position"
        private const val KEY_X = "last_x"
        private const val KEY_Y = "last_y"
        private const val KEY_ON_RIGHT = "on_right"
        fun distance(x1: Float, x2: Float, y1: Float, y2: Float): Float {
            return ((x1 - x2).pow(2) + (y1-y2).pow(2))
        }
    }
    var wasMoving = false
    var captured = false
    var movingOutOfClose = false
    private var initialX = 0.0f
    private var initialY = 0.0f
    private var initialTouchX = 0.0f
    private var initialTouchY = 0.0f
    private var initialVelocityX = 0.0
    private var initialVelocityY = 0.0
    private var lastY = 0.0
    private var moving = false
    var toggled = false
        private set
    private var motionTrackerUpdated = false
    private var collapsing = false
    private var blockAnim = false
    private var horizontalSpringChain: SpringChain? = null
    private var verticalSpringChain: SpringChain? = null
    private var isOnRight = false
    private var velocityTracker: VelocityTracker? = null
    private var motionTracker = LinearLayout(context)
    var topChatHead: ChatHead? = null
    var content = FlutterContentPanel(context)
    private var close = Close(this)
    var chatHeads = ArrayList<ChatHead>()

    // ── Persistent position ───────────────────────────────────────────
    private val prefs: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    private var motionTrackerParams = WindowManager.LayoutParams(
        CHAT_HEAD_SIZE,
        CHAT_HEAD_SIZE + 16,
            WindowManagerHelper.getLayoutFlag(),
        WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
        PixelFormat.TRANSLUCENT
    )

    private var params = WindowManager.LayoutParams(
        WindowManager.LayoutParams.MATCH_PARENT,
        WindowManager.LayoutParams.MATCH_PARENT,
            WindowManagerHelper.getLayoutFlag(),
        WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
        PixelFormat.TRANSLUCENT
    )

    // ── Debug overlay ──────────────────────────────────────────────
    private var debugOverlayView: DebugOverlayView? = null

    init {
        context.setTheme(com.google.android.material.R.style.Theme_MaterialComponents_Light)
        params.gravity = Gravity.START or Gravity.TOP
        params.dimAmount = 0.7f
        motionTrackerParams.gravity = Gravity.START or Gravity.TOP
        // ── Accessibility: hide touch proxy from TalkBack ──────────
        motionTracker.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        FloatyContentJobService.instance?.windowManager?.addView(motionTracker, motionTrackerParams)
        FloatyContentJobService.instance?.windowManager?.addView(this, params)
        this.addView(content)

        // ── Debug overlay ────────────────────────────────────────────
        if (OverlayConfig.debugMode) {
            debugOverlayView = DebugOverlayView(this)
        }

        motionTracker.setOnTouchListener(this)
        this.setOnTouchListener{ v, event ->
            v.performClick()
            when (event.action) {
                MotionEvent.ACTION_UP -> {
                    if (v == this) {
                        collapse()
                    }
                }

            }
            return@setOnTouchListener false
        }
    }

    // ── Snap helpers ──────────────────────────────────────────────────

    /** Pixel offset from screen edge when snapped (converted from dp). */
    private fun snapOffsetPx(): Int {
        val margin = OverlayConfig.snapMargin
        return if (margin < 0) {
            // Negative margin = partially hidden (like CHAT_HEAD_OUT_OF_SCREEN_X)
            WindowManagerHelper.dpToPx(abs(margin))
        } else {
            // Positive margin = gap from edge. We negate so the math
            // in fixPositions (which subtracts offset) pushes inward.
            -WindowManagerHelper.dpToPx(margin)
        }
    }

    /**
     * Resolve the X position the chathead should snap to based on the
     * configured [SnapEdge].
     *
     * @param currentX  current horizontal position of the chathead
     * @param width     chathead width in px
     * @return Pair(endX, onRight)
     */
    private fun resolveSnapX(currentX: Double, width: Int): Pair<Double, Boolean> {
        val metrics = WindowManagerHelper.getScreenSize()
        val offset = snapOffsetPx()
        return when (OverlayConfig.snapEdge) {
            SnapEdge.LEFT -> {
                Pair(-offset.toDouble(), false)
            }
            SnapEdge.RIGHT -> {
                Pair(metrics.widthPixels - width + offset.toDouble(), true)
            }
            SnapEdge.NONE -> {
                // No snapping — stay where released.
                Pair(currentX, currentX >= metrics.widthPixels / 2)
            }
            SnapEdge.BOTH -> {
                if (currentX + width / 2 >= metrics.widthPixels / 2) {
                    Pair(metrics.widthPixels - width + offset.toDouble(), true)
                } else {
                    Pair(-offset.toDouble(), false)
                }
            }
        }
    }

    // ── Position persistence helpers ──────────────────────────────────

    private fun savePosition(x: Double, y: Double, onRight: Boolean) {
        if (!OverlayConfig.persistPosition) return
        prefs.edit()
            .putFloat(KEY_X, x.toFloat())
            .putFloat(KEY_Y, y.toFloat())
            .putBoolean(KEY_ON_RIGHT, onRight)
            .apply()
    }

    private data class SavedPosition(val x: Float, val y: Float, val onRight: Boolean)

    private fun loadPosition(): SavedPosition? {
        if (!OverlayConfig.persistPosition) return null
        if (!prefs.contains(KEY_X)) return null
        return SavedPosition(
            prefs.getFloat(KEY_X, 0f),
            prefs.getFloat(KEY_Y, 0f),
            prefs.getBoolean(KEY_ON_RIGHT, false),
        )
    }

    fun setTop(chatHead: ChatHead) {
        topChatHead?.isTop = false
        chatHead.isTop = true
        topChatHead = chatHead
    }

    fun fixPositions(animation: Boolean = true) {
        if (topChatHead == null) return
        val offset = snapOffsetPx()
        val metrics = WindowManagerHelper.getScreenSize()
        val newX = if (isOnRight) {
            metrics.widthPixels - topChatHead!!.width + offset.toDouble()
        } else {
            -offset.toDouble()
        }
        val newY = initialY.toDouble()
        if (animation) {
            topChatHead!!.springX.endValue = newX
            topChatHead!!.springY.endValue = newY
        } else {
            topChatHead!!.springX.currentValue = newX
            topChatHead!!.springY.currentValue = newY
        }
        savePosition(newX, newY, isOnRight)
    }

    private fun destroySpringChains() {
        horizontalSpringChain?.let {
            for (spring in it.allSprings) {
                spring.destroy()
            }
        }
        verticalSpringChain?.let {
            for (spring in it.allSprings) {
                spring.destroy()
            }
        }
        verticalSpringChain = null
        horizontalSpringChain = null
    }

    @SuppressLint("NewApi")
    private fun resetSpringChains() {
       destroySpringChains()
        horizontalSpringChain = SpringChain.create(0, 0, 200, 15)
        verticalSpringChain = SpringChain.create(0, 0, 200, 15)
        chatHeads.forEachIndexed { index, element ->
            element.z = index.toFloat()
            if (element.isTop) {
                horizontalSpringChain!!.addSpring(object : SimpleSpringListener() { })
                verticalSpringChain!!.addSpring(object : SimpleSpringListener() { })

                element.z = chatHeads.size.toFloat()
                horizontalSpringChain!!.setControlSpringIndex(index)
                verticalSpringChain!!.setControlSpringIndex(index)
            } else {
                horizontalSpringChain!!.addSpring(object : SimpleSpringListener() {
                    override fun onSpringUpdate(spring: Spring?) {
                        if (!toggled && !blockAnim) {
                            if (collapsing) {
                                element.springX.endValue = spring!!.endValue + (chatHeads.size - 1 - index) * CHAT_HEAD_PADDING * if (isOnRight) 1 else -1
                            } else {
                                element.springX.currentValue = spring!!.currentValue + (chatHeads.size - 1 - index) * CHAT_HEAD_PADDING * if (isOnRight) 1 else -1
                            }
                        }
                    }
                })
                verticalSpringChain!!.addSpring(object : SimpleSpringListener() {
                    override fun onSpringUpdate(spring: Spring?) {
                        if (!toggled && !blockAnim) {
                            element.springY.currentValue = spring!!.currentValue
                        }
                    }
                })
            }
        }
    }

    fun add(id: String = "default", icon: android.graphics.Bitmap? = null): ChatHead {
        OverlayConfig.logD("add() id=$id, entranceAnim=${OverlayConfig.entranceAnimation}, childCount=$childCount")
        chatHeads.forEach {
            it.visibility = View.VISIBLE
        }
        val chatHead = ChatHead(this, id = id, iconBitmap = icon)
        chatHeads.add(chatHead)

        // Determine initial position (restore or default).
        var lx: Double
        var ly: Double
        val saved = loadPosition()
        if (saved != null && topChatHead == null) {
            // First chathead with a saved position — restore it.
            lx = saved.x.toDouble()
            ly = saved.y.toDouble()
            isOnRight = saved.onRight
            initialY = saved.y
        } else if (topChatHead != null) {
            lx = topChatHead!!.springX.currentValue
            ly = topChatHead!!.springY.currentValue
        } else {
            lx = -snapOffsetPx().toDouble()
            ly = 0.0
        }

        setTop(chatHead)
        destroySpringChains()
        resetSpringChains()

        blockAnim = true

        chatHeads.forEachIndexed { index, element ->
            element.springX.currentValue = lx + (chatHeads.size - 1 - index) * CHAT_HEAD_PADDING * if (isOnRight) 1 else -1
            element.springY.currentValue = ly
        }

        // ── Entrance animation ────────────────────────────────────────
        when (OverlayConfig.entranceAnimation) {
            EntranceAnimation.POP -> {
                chatHead.scaleX = 0f
                chatHead.scaleY = 0f
                chatHead.animate()
                    .scaleX(1f).scaleY(1f)
                    .setDuration(350)
                    .setInterpolator(android.view.animation.OvershootInterpolator(1.2f))
                    .start()
            }
            EntranceAnimation.SLIDE_FROM_EDGE -> {
                val metrics = WindowManagerHelper.getScreenSize()
                val startX = if (isOnRight) metrics.widthPixels.toDouble() + chatHead.width
                             else -(chatHead.width.toDouble() * 2)
                chatHead.springX.currentValue = startX
                chatHead.springX.springConfig = SpringConfigs.NOT_DRAGGING
                chatHead.springX.endValue = lx
            }
            EntranceAnimation.FADE -> {
                chatHead.alpha = 0f
                chatHead.animate()
                    .alpha(1f)
                    .setDuration(400)
                    .start()
            }
            EntranceAnimation.NONE -> { /* no-op */ }
        }

        motionTrackerParams.x = chatHead.springX.currentValue.toInt()
        motionTrackerParams.y = chatHead.springY.currentValue.toInt()
        motionTrackerParams.flags = motionTrackerParams.flags and WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE.inv()

        FloatyContentJobService.instance?.windowManager?.updateViewLayout(motionTracker, motionTrackerParams)

        return chatHead
    }

    fun collapse() {
        toggled = false
        collapsing = true

        fixPositions()

        val activeId = chatHeads.find { it.isActive }?.id ?: topChatHead?.id ?: "default"

        chatHeads.forEach {
            it.isActive = false
        }
        content.hideContent()
        motionTrackerParams.flags = motionTrackerParams.flags and WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE.inv()
        FloatyContentJobService.instance?.windowManager?.updateViewLayout(motionTracker, motionTrackerParams)

        params.flags = ((params.flags or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE) and WindowManager.LayoutParams.FLAG_DIM_BEHIND.inv()) and WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL.inv() or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
        FloatyContentJobService.instance?.windowManager?.updateViewLayout(this, params)

        // Accessibility: announce state + move focus back to bubble
        announceForAccessibility("Chat collapsed")
        topChatHead?.requestFocus()

        // Notify lifecycle: collapsed
        FloatyContentJobService.instance?.notifyChatHeadCollapsed(activeId)
    }

    fun changeContent() {
        val chatHead = chatHeads.find { it.isActive } ?: return
        FloatyContentJobService.instance?.notifyChatHeadTapped(chatHead.id)
    }

    fun remove(id: String) {
        val chatHead = chatHeads.find { it.id == id } ?: return
        val wasActive = chatHead.isActive
        val wasTop = chatHead.isTop

        chatHeads.remove(chatHead)
        removeView(chatHead)

        if (chatHeads.isEmpty()) {
            FloatyContentJobService.instance?.closeWindow(true)
            return
        }

        if (wasTop || wasActive) {
            val newTop = chatHeads.last()
            setTop(newTop)
            if (wasActive) {
                newTop.isActive = true
                changeContent()
            }
        }

        destroySpringChains()
        resetSpringChains()
        fixPositions()
    }

    fun getRunningServiceInfo(serviceClass: Class<*>, context: Context): ActivityManager.RunningServiceInfo? {
        val manager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        for (service in manager.getRunningServices(Integer.MAX_VALUE)) {
            if (serviceClass.name == service.service.className) {
                return service
            }
        }
        return null
    }

    /** Remove the motionTracker and spring chains that live outside this view. */
    fun cleanup() {
        destroySpringChains()
        try {
            FloatyContentJobService.instance?.windowManager?.removeView(motionTracker)
        } catch (_: Exception) {
            // Already removed or never attached — safe to ignore.
        }
    }

    fun hideChatHeads(isClosed: Boolean = false) {
        close.hide()
        postDelayed({
            topChatHead?.let {
                it.springY.currentValue = 0.0
                it.springX.currentValue = 0.0
            }
            if (isClosed) {
                FloatyContentJobService.instance?.closeWindow(true)
            }
        }, HIDE_DELAY_MS)
    }

    /** Programmatically expand the chathead and show the content panel. */
    fun expand() {
        OverlayConfig.logD("expand() called. toggled=$toggled, topChatHead=${topChatHead?.id}")
        if (toggled || topChatHead == null) return
        val metrics = WindowManagerHelper.getScreenSize()

        toggled = true
        chatHeads.forEachIndexed { index, it ->
            it.springX.springConfig = SpringConfigs.NOT_DRAGGING
            it.springY.springConfig = SpringConfigs.NOT_DRAGGING
            it.springY.endValue = CHAT_HEAD_EXPANDED_MARGIN_TOP.toDouble()
            it.springX.endValue = metrics.widthPixels - topChatHead!!.width.toDouble() - (chatHeads.size - 1 - index) * (it.width + CHAT_HEAD_EXPANDED_PADDING).toDouble()
        }
        motionTrackerParams.flags = motionTrackerParams.flags or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
        FloatyContentJobService.instance?.windowManager?.updateViewLayout(motionTracker, motionTrackerParams)
        params.flags = (params.flags and WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE.inv()) or WindowManager.LayoutParams.FLAG_DIM_BEHIND or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL and WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE.inv()
        FloatyContentJobService.instance?.windowManager?.updateViewLayout(this, params)
        topChatHead!!.isActive = true
        changeContent()
        Handler(Looper.getMainLooper()).postDelayed(
            {
                content.showContent()
                // Accessibility: announce state + move focus to content panel
                announceForAccessibility("Chat expanded")
                content.sendAccessibilityEvent(android.view.accessibility.AccessibilityEvent.TYPE_VIEW_FOCUSED)

                // Notify lifecycle: expanded
                FloatyContentJobService.instance?.notifyChatHeadExpanded(topChatHead?.id ?: "default")
            }, EXPAND_CONTENT_DELAY_MS
        )
    }

    /** Replace the icon bitmap of a specific chathead. */
    fun updateChatHeadIcon(id: String, bitmap: android.graphics.Bitmap) {
        val target = chatHeads.find { it.id == id } ?: topChatHead
        target?.updateIcon(bitmap)
    }

    /** Update the badge count on the top chathead (or a specific chathead by id). */
    fun updateBadge(count: Int, id: String? = null) {
        val target = if (id != null) chatHeads.find { it.id == id } else topChatHead
        target?.badgeCount = count
    }

    fun onSpringUpdate(chatHead: ChatHead, spring: Spring, totalVelocity: Int) {
        val metrics = WindowManagerHelper.getScreenSize()
        val top = topChatHead ?: return
        if (chatHead == top) {
            if (spring == chatHead.springX) {
                horizontalSpringChain?.controlSpring?.let { it.currentValue = spring.currentValue }
            }
            if (spring == chatHead.springY) {
                verticalSpringChain?.controlSpring?.let { it.currentValue = spring.currentValue }
            }
        }
        val tmpChatHead = if (collapsing) top else if (chatHead.isActive) chatHead else null
        if (tmpChatHead != null) {
            val newX = tmpChatHead.springX.currentValue.toFloat() - metrics.widthPixels.toFloat() + ((chatHeads.size - 1 - chatHeads.indexOf(tmpChatHead)) * (tmpChatHead.width + CHAT_HEAD_EXPANDED_PADDING)) + tmpChatHead.width
            val newY = tmpChatHead.springY.currentValue.toFloat() - CHAT_HEAD_EXPANDED_MARGIN_TOP
            content.x = newX
            content.y = newY
            content.pivotX = metrics.widthPixels.toFloat() - chatHead.width / 2 - ((chatHeads.size - 1 - chatHeads.indexOf(tmpChatHead)) * (tmpChatHead.width + CHAT_HEAD_EXPANDED_PADDING))
            if (toggled && totalVelocity % 100 == 0) {
                OverlayConfig.logD("onSpringUpdate: content.x=$newX, content.y=$newY, content.visibility=${content.visibility}, content.scaleX=${content.scaleX}, content.scaleY=${content.scaleY}, content.w=${content.width}, content.h=${content.height}")
            }
        }
        content.pivotY = chatHead.height.toFloat()
        if (!moving && distance(close.x, top.springX.currentValue.toFloat(), close.y, top.springY.currentValue.toFloat()) < CLOSE_CAPTURE_DISTANCE * CLOSE_CAPTURE_DISTANCE && !captured && close.visibility == View.VISIBLE) {
            top.springX.springConfig = SpringConfigs.CAPTURING
            top.springY.springConfig = SpringConfigs.CAPTURING
            top.springX.endValue = close.springX.endValue
            top.springY.endValue = close.springY.endValue
            postDelayed({
                hideChatHeads(false)
            }, HIDE_DELAY_MS)
            captured = true
        }
        if (wasMoving) {
            motionTrackerParams.x = if (isOnRight) metrics.widthPixels - chatHead.width else 0
            lastY = chatHead.springY.currentValue
            if (abs(chatHead.springY.velocity) > 3000 && (chatHead.springX.currentValue > metrics.widthPixels - chatHead.width + CHAT_HEAD_OUT_OF_SCREEN_X / 2 || chatHead.springX.currentValue < -CHAT_HEAD_OUT_OF_SCREEN_X / 2) && abs(initialVelocityX) > 3000) {
                chatHead.springY.velocity = 3000.0 * if (initialVelocityY < 0) -1 else 1
            }
            if ((chatHead.springX.currentValue < -CHAT_HEAD_OUT_OF_SCREEN_X / 2 && initialVelocityX < -3000 || chatHead.springX.currentValue > metrics.widthPixels - chatHead.width  + CHAT_HEAD_OUT_OF_SCREEN_X / 2) && abs(initialVelocityY) < abs(initialVelocityX)) {
                chatHead.springY.velocity = 0.0
            }
            if (abs(chatHead.springY.velocity) > 500) {
                if (chatHead.springY.currentValue < 0) {
                    chatHead.springY.velocity = -500.0
                } else if (chatHead.springY.currentValue > metrics.heightPixels) {
                    chatHead.springY.velocity = 500.0
                }
            }

            if (!moving) {
                if (spring === chatHead.springX) {
                    val xPosition = chatHead.springX.currentValue
                    if (xPosition + chatHead.width > metrics.widthPixels && chatHead.springX.velocity > 0) {
                        val (snapX, snapRight) = resolveSnapX(xPosition, chatHead.width)
                        chatHead.springX.springConfig = SpringConfigs.NOT_DRAGGING
                        chatHead.springX.endValue = snapX
                        isOnRight = snapRight
                        savePosition(snapX, chatHead.springY.currentValue, isOnRight)
                    } else if (xPosition < 0 && chatHead.springX.velocity < 0) {
                        val (snapX, snapRight) = resolveSnapX(xPosition, chatHead.width)
                        chatHead.springX.springConfig = SpringConfigs.NOT_DRAGGING
                        chatHead.springX.endValue = snapX
                        isOnRight = snapRight
                        savePosition(snapX, chatHead.springY.currentValue, isOnRight)
                    }
                } else if (spring === chatHead.springY) {
                    val yPosition = chatHead.springY.currentValue
                    if (yPosition + chatHead.height > metrics.heightPixels && chatHead.springY.velocity > 0) {
                        chatHead.springY.springConfig = SpringConfigs.NOT_DRAGGING
                        chatHead.springY.endValue = metrics.heightPixels - chatHead.height.toDouble() -
                                WindowManagerHelper.dpToPx(25f)
                    } else if (yPosition < 0 && chatHead.springY.velocity < 0) {
                        chatHead.springY.springConfig = SpringConfigs.NOT_DRAGGING
                        chatHead.springY.endValue = 0.0
                    }
                }
            }

            if (abs(totalVelocity) % 10 == 0 && !moving) {
                motionTrackerParams.y = top.springY.currentValue.toInt()
                FloatyContentJobService.instance?.windowManager?.updateViewLayout(motionTracker, motionTrackerParams)
            }
        }
    }

    override fun onTouch(v: View?, event: MotionEvent?): Boolean {
        val metrics = WindowManagerHelper.getScreenSize()
        if (topChatHead == null) return true
        when (event!!.action) {
            MotionEvent.ACTION_DOWN -> {
                topChatHead?.let {
                    initialX = it.springX.currentValue.toFloat()
                    initialY = it.springY.currentValue.toFloat()
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    wasMoving = false
                    collapsing = false
                    blockAnim = false
                    close.show()
                    it.scaleX = 0.9f
                    it.scaleY = 0.9f
                    it.springX.springConfig = SpringConfigs.DRAGGING
                    it.springY.springConfig = SpringConfigs.DRAGGING
                    it.springX.setAtRest()
                    it.springY.setAtRest()
                }
                motionTrackerUpdated = false
                when (velocityTracker) {
                    null -> velocityTracker = VelocityTracker.obtain()
                    else -> velocityTracker?.clear()
                }
                velocityTracker?.addMovement(event)
            }
            MotionEvent.ACTION_UP -> {
                if (moving) wasMoving = true
                postDelayed({
                    close.hide()
                    if (captured) {
                        hideChatHeads(true)
                    }
                }, CLOSE_DELAY_MS)
                if (captured) return true
                if (!moving) {
                    if (!toggled) {
                        OverlayConfig.logD("EXPAND: toggled=false, entering expand flow. topChatHead=${topChatHead?.id}, chatHeads.size=${chatHeads.size}")
                        toggled = true
                        chatHeads.forEachIndexed { index, it ->
                            it.springX.springConfig = SpringConfigs.NOT_DRAGGING
                            it.springY.springConfig = SpringConfigs.NOT_DRAGGING
                            it.springY.endValue = CHAT_HEAD_EXPANDED_MARGIN_TOP.toDouble()
                            it.springX.endValue = metrics.widthPixels - topChatHead!!.width.toDouble() - (chatHeads.size - 1 - index) * (it.width + CHAT_HEAD_EXPANDED_PADDING).toDouble()
                        }
                        motionTrackerParams.flags = motionTrackerParams.flags or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
                        FloatyContentJobService.instance?.windowManager?.updateViewLayout(motionTracker, motionTrackerParams)
                        params.flags = (params.flags and WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE.inv()) or WindowManager.LayoutParams.FLAG_DIM_BEHIND or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL and WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE.inv()
                        FloatyContentJobService.instance?.windowManager?.updateViewLayout(this, params)
                        topChatHead!!.isActive = true
                        changeContent()
                        OverlayConfig.logD("EXPAND: scheduling showContent() in 200ms. content.visibility=${content.visibility}, content.childCount=${content.childCount}")
                        Handler(Looper.getMainLooper()).postDelayed(
                            {
                                OverlayConfig.logD("EXPAND: postDelayed fired. Calling content.showContent(). content.visibility=${content.visibility}")
                                content.showContent()
                                // Accessibility: announce state + move focus to content panel
                                announceForAccessibility("Chat expanded")
                                content.sendAccessibilityEvent(android.view.accessibility.AccessibilityEvent.TYPE_VIEW_FOCUSED)

                                // Notify lifecycle: expanded
                                FloatyContentJobService.instance?.notifyChatHeadExpanded(topChatHead?.id ?: "default")
                            }, EXPAND_CONTENT_DELAY_MS
                        )
                    } else {
                        OverlayConfig.logD("EXPAND: toggled=true, already expanded — skipping")
                    }
                } else if (!toggled) {
                    moving = false
                    var xVelocity = velocityTracker!!.xVelocity.toDouble()
                    val yVelocity = velocityTracker!!.yVelocity.toDouble()
                    var maxVelocityX = 0.0
                    velocityTracker?.recycle()
                    velocityTracker = null

                    // Notify lifecycle: drag end
                    FloatyContentJobService.instance?.notifyChatHeadDragEnd(
                        topChatHead?.id ?: "default",
                        topChatHead?.springX?.currentValue ?: 0.0,
                        topChatHead?.springY?.currentValue ?: 0.0,
                    )

                    if (xVelocity < -3500) {
                        val newVelocity = ((-topChatHead!!.springX.currentValue -  CHAT_HEAD_OUT_OF_SCREEN_X) * SpringConfigs.DRAGGING.friction)
                        maxVelocityX = newVelocity - 5000
                        if (xVelocity > maxVelocityX)
                            xVelocity = newVelocity - 500
                    } else if (xVelocity > 3500) {
                        val newVelocity = ((metrics.widthPixels - topChatHead!!.springX.currentValue - topChatHead!!.width + CHAT_HEAD_OUT_OF_SCREEN_X) * SpringConfigs.DRAGGING.friction)
                        maxVelocityX = newVelocity + 5000
                        if (maxVelocityX > xVelocity)
                            xVelocity = newVelocity + 500
                    } else if (yVelocity > 20 || yVelocity < -20) {
                        topChatHead!!.springX.springConfig = SpringConfigs.NOT_DRAGGING
                        val (snapX, snapRight) = resolveSnapX(
                            topChatHead!!.springX.currentValue,
                            topChatHead!!.width,
                        )
                        topChatHead!!.springX.endValue = snapX
                        isOnRight = snapRight
                        savePosition(snapX, topChatHead!!.springY.currentValue, isOnRight)
                    } else {
                        topChatHead!!.springX.springConfig = SpringConfigs.NOT_DRAGGING
                        topChatHead!!.springY.springConfig = SpringConfigs.NOT_DRAGGING
                        val (snapX, snapRight) = resolveSnapX(
                            topChatHead!!.springX.currentValue,
                            topChatHead!!.width,
                        )
                        topChatHead!!.springX.endValue = snapX
                        topChatHead!!.springY.endValue = topChatHead!!.y.toDouble()
                        isOnRight = snapRight
                        savePosition(snapX, topChatHead!!.y.toDouble(), isOnRight)
                    }
                    if (xVelocity < 0) {
                        topChatHead!!.springX.velocity = max(xVelocity, maxVelocityX)
                    } else {
                        topChatHead!!.springX.velocity = min(xVelocity, maxVelocityX)
                    }
                    initialVelocityX = topChatHead!!.springX.velocity
                    initialVelocityY = topChatHead!!.springY.velocity
                    topChatHead!!.springY.velocity = yVelocity
                }
                topChatHead!!.scaleX = 1f
                topChatHead!!.scaleY = 1f
            }
            MotionEvent.ACTION_MOVE -> {
                if (distance(initialTouchX, event.rawX, initialTouchY, event.rawY) > CHAT_HEAD_DRAG_TOLERANCE.pow(2)) {
                    if (!moving) {
                        // Accessibility announcement
                        announceForAccessibility("Dragging chat bubble")
                        // Notify lifecycle: drag start (only once per gesture)
                        FloatyContentJobService.instance?.notifyChatHeadDragStart(
                            topChatHead?.id ?: "default",
                            topChatHead?.springX?.currentValue ?: 0.0,
                            topChatHead?.springY?.currentValue ?: 0.0,
                        )
                    }
                    moving = true
                }
                velocityTracker?.addMovement(event)
                if (moving) {
                    close.springX.endValue = (metrics.widthPixels / 2) + (((event.rawX + topChatHead!!.width / 2) / 7) - metrics.widthPixels / 2 / 7) - close.width.toDouble() / 2
                    close.springY.endValue = (metrics.heightPixels - CLOSE_SIZE) + max(((event.rawY + close.height / 2) / 10) - metrics.heightPixels / 10, -WindowManagerHelper.dpToPx(30f).toFloat()) - WindowManagerHelper.dpToPx(60f).toDouble()
                    if (distance(close.x + close.width / 2, event.rawX, close.y + close.height / 2, event.rawY) < CLOSE_CAPTURE_DISTANCE * CLOSE_CAPTURE_DISTANCE) {
                        topChatHead!!.springX.springConfig = SpringConfigs.CAPTURING
                        topChatHead!!.springY.springConfig = SpringConfigs.CAPTURING
                        close.springScale.endValue = CLOSE_ADDITIONAL_SIZE.toDouble()
                        captured = true
                    } else if (captured) {
                        topChatHead!!.springX.springConfig = SpringConfigs.CAPTURING
                        topChatHead!!.springY.springConfig = SpringConfigs.CAPTURING
                        close.springScale.endValue = 0.0
                        topChatHead!!.springX.endValue = initialX + (event.rawX - initialTouchX).toDouble()
                        topChatHead!!.springY.endValue = initialY + (event.rawY - initialTouchY).toDouble()
                        captured = false
                        movingOutOfClose = true
                        postDelayed({ movingOutOfClose = false }, 100)
                    } else if (!movingOutOfClose) {
                        topChatHead!!.springX.springConfig = SpringConfigs.DRAGGING
                        topChatHead!!.springY.springConfig = SpringConfigs.DRAGGING
                        topChatHead!!.springX.currentValue = initialX + (event.rawX - initialTouchX).toDouble()
                        topChatHead!!.springY.currentValue = initialY + (event.rawY - initialTouchY).toDouble()
                        velocityTracker?.computeCurrentVelocity(2000)
                    }
                }
            }
        }
        return true
    }
}
