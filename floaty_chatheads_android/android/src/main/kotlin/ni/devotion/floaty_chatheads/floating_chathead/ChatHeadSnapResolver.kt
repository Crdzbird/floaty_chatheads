package ni.devotion.floaty_chatheads.floating_chathead

import ni.devotion.floaty_chatheads.utils.OverlayConfig
import ni.devotion.floaty_chatheads.utils.SnapEdge
import kotlin.math.abs

/**
 * Pure-math helpers for resolving where the chathead snaps after a
 * drag, based on [OverlayConfig.snapEdge] and
 * [OverlayConfig.snapMargin].
 *
 * No state, no side effects — safe to call from any thread, though in
 * practice it is invoked from the UI thread inside ChatHeads.kt.
 */
internal object ChatHeadSnapResolver {

    /**
     * Snap result: target X in px and whether the chathead lands on the
     * right edge of the screen.
     */
    data class Snap(val endX: Double, val onRight: Boolean)

    /**
     * Pixel offset from the screen edge when snapped.
     *
     * Negative margins mean "partially hidden" (the bubble overlaps the
     * edge — matches the historical [ChatHeads.CHAT_HEAD_OUT_OF_SCREEN_X]
     * look). Positive margins are converted to a gap from the edge —
     * the math in [resolve] expects an inward push, so the returned
     * value is negated for positive inputs.
     */
    fun snapOffsetPx(): Int {
        val margin = OverlayConfig.snapMargin
        return if (margin < 0) {
            WindowManagerHelper.dpToPx(abs(margin))
        } else {
            -WindowManagerHelper.dpToPx(margin)
        }
    }

    /**
     * Picks the X position the chathead should snap to.
     *
     * @param currentX  current horizontal position of the chathead (px)
     * @param width     chathead width in px
     */
    fun resolve(currentX: Double, width: Int): Snap {
        val metrics = WindowManagerHelper.getScreenSize()
        val offset = snapOffsetPx()
        return when (OverlayConfig.snapEdge) {
            SnapEdge.LEFT ->
                Snap(-offset.toDouble(), onRight = false)
            SnapEdge.RIGHT ->
                Snap(metrics.widthPixels - width + offset.toDouble(), onRight = true)
            SnapEdge.NONE ->
                // No snapping — stay where released; classify side by halfway point.
                Snap(currentX, onRight = currentX >= metrics.widthPixels / 2)
            SnapEdge.BOTH ->
                if (currentX + width / 2 >= metrics.widthPixels / 2) {
                    Snap(metrics.widthPixels - width + offset.toDouble(), onRight = true)
                } else {
                    Snap(-offset.toDouble(), onRight = false)
                }
        }
    }
}
