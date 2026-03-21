package ni.devotion.floaty_chatheads.utils

object Constants {
    const val OVERLAY_ENGINE_CACHE_TAG = "floaty_chathead_overlay_engine"
    const val MESSENGER_TAG = "ni.devotion.floaty_head/messenger"
    const val NOTIFICATION_CHANNEL_ID = "FloatyChatheadServiceChannel"
    const val NOTIFICATION_ID = 4580

    // SharedPreferences keys for overlay survival after app death.
    const val PREFS_NAME = "floaty_chatheads_prefs"
    const val PREF_ENTRY_POINT = "entry_point"
    const val PREF_CONTENT_WIDTH = "content_width"
    const val PREF_CONTENT_HEIGHT = "content_height"
    const val PREF_SNAP_EDGE = "snap_edge"
    const val PREF_SNAP_MARGIN = "snap_margin"
    const val PREF_PERSIST_POSITION = "persist_position"
    const val PREF_ENTRANCE_ANIMATION = "entrance_animation"
    const val PREF_DEBUG_MODE = "debug_mode"
    const val PREF_NOTIFICATION_TITLE = "notification_title"
    const val PREF_NOTIFICATION_DESCRIPTION = "notification_description"
    const val PREF_BADGE_COLOR = "badge_color"
    const val PREF_BADGE_TEXT_COLOR = "badge_text_color"
    const val PREF_BUBBLE_BORDER_COLOR = "bubble_border_color"
    const val PREF_BUBBLE_BORDER_WIDTH = "bubble_border_width"
    const val PREF_BUBBLE_SHADOW_COLOR = "bubble_shadow_color"
    const val PREF_CLOSE_TINT_COLOR = "close_tint_color"
    const val PREF_OVERLAY_PALETTE = "overlay_palette"
    const val PREF_HAS_SAVED_CONFIG = "has_saved_config"

    // Connection state prefix for Dart channel.
    const val CONNECTION_PREFIX = "_floaty_connection"

    // System envelope key used by FloatyChannel to distinguish system
    // messages from raw user data.
    const val SYSTEM_ENVELOPE = "__floaty__"
    const val THEME_PREFIX = "_floaty_theme"
    const val CLOSED_PREFIX = "_floaty_closed"
}
