# Rebound spring physics is used directly (no reflection), but keep it
# whole so consumer R8 configurations cannot strip listener callbacks.
-keep class com.facebook.rebound.** { *; }
