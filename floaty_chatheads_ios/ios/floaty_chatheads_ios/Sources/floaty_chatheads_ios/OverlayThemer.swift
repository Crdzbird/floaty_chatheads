import UIKit

/// Applies the optional [ChatHeadThemeMessage] to a [UIWindow]'s
/// `CALayer` border/shadow. Mirrors the Android `ChatHeadTheme`
/// fields exactly — colors arrive as ARGB int from the Dart side and
/// are decoded by `UIColor(argb:)`.
@MainActor
enum OverlayThemer {
    static func apply(to window: UIWindow, theme: ChatHeadThemeMessage?) {
        guard let theme = theme else { return }

        if let borderColor = theme.bubbleBorderColor {
            window.layer.borderColor = UIColor(argb: borderColor).cgColor
        }
        if let borderWidth = theme.bubbleBorderWidth {
            window.layer.borderWidth = CGFloat(borderWidth)
        }
        if let shadowColor = theme.bubbleShadowColor {
            window.layer.shadowColor = UIColor(argb: shadowColor).cgColor
            window.layer.shadowOpacity = 0.3
            window.layer.shadowOffset = CGSize(width: 0, height: 2)
            window.layer.shadowRadius = 4
        }
    }
}
