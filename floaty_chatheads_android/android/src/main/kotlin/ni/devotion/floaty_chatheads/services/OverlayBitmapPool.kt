package ni.devotion.floaty_chatheads.services

import android.graphics.Bitmap

/**
 * A single-slot bitmap pool used by `updateChatHeadIcon` to avoid
 * per-frame ARGB_8888 allocations during animated icon updates at
 * 20-30 fps. The slot is reused only when the requested dimensions
 * match the cached bitmap.
 *
 * Not thread-safe: callers must coordinate access (the plugin uses
 * `Dispatchers.Default` inside a single coroutine per update).
 */
internal class OverlayBitmapPool(
    private val maxDimension: Long = MAX_ICON_DIMENSION,
) {
    companion object {
        /** Max width/height (px) accepted by [validateOrReject]. */
        const val MAX_ICON_DIMENSION = 4096L
    }

    private var reusable: Bitmap? = null

    /**
     * Validates that [width] and [height] are positive, within
     * [maxDimension], and that [actualByteCount] equals the expected
     * `width * height * 4` (RGBA_8888).
     */
    fun validateOrReject(
        width: Long,
        height: Long,
        actualByteCount: Int,
    ): Boolean {
        val expected = width * height * 4L
        return width > 0 &&
            height > 0 &&
            width <= maxDimension &&
            height <= maxDimension &&
            actualByteCount.toLong() == expected
    }

    /**
     * Returns a mutable ARGB_8888 bitmap of [width] x [height],
     * reusing the cached instance when dimensions match.
     */
    fun obtainOrCreate(width: Int, height: Int): Bitmap {
        val cached = reusable
        if (cached != null &&
            cached.width == width &&
            cached.height == height &&
            !cached.isRecycled
        ) {
            return cached
        }
        return Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            .also { reusable = it }
    }
}
