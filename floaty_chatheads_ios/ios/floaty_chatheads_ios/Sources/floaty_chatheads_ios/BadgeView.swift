import UIKit

/// Owns the small numeric badge rendered at the top-right of the
/// chathead window. Lives in its own file so badge sizing / theming
/// is decoupled from window lifecycle.
@MainActor
final class BadgeView {

    private weak var hostWindow: UIWindow?
    private var label: UILabel?

    /// Theme-resolved colors. Re-applied on each [install]. Defaults
    /// match the legacy hard-coded look (red bg, white text).
    var backgroundColor: UIColor = .red
    var textColor: UIColor = .white

    /// Current count. `0` hides the badge.
    private(set) var count: Int = 0

    /// Creates and installs the label on [window]. Subsequent calls
    /// remove the previous label first.
    func install(on window: UIWindow) {
        remove()
        hostWindow = window

        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = textColor
        label.backgroundColor = backgroundColor
        label.clipsToBounds = true
        label.isHidden = true

        let badgeSize: CGFloat = 18
        label.frame = CGRect(
            x: window.frame.width - badgeSize / 2,
            y: -badgeSize / 2,
            width: badgeSize,
            height: badgeSize,
        )
        label.layer.cornerRadius = badgeSize / 2

        window.addSubview(label)
        self.label = label
    }

    /// Updates the displayed count, resizing for 2+ digit numbers.
    func setCount(_ value: Int) {
        count = value
        guard let label = label else { return }

        if value <= 0 {
            label.isHidden = true
            hostWindow?.accessibilityValue = nil
            return
        }

        label.isHidden = false
        let displayText = value > 99 ? "99+" : "\(value)"
        label.text = displayText

        let textWidth = (displayText as NSString)
            .size(withAttributes: [.font: label.font!]).width
        let badgeWidth = max(18, textWidth + 8)
        let badgeHeight: CGFloat = 18
        if let window = hostWindow {
            label.frame = CGRect(
                x: window.frame.width - badgeWidth / 2,
                y: -badgeHeight / 2,
                width: badgeWidth,
                height: badgeHeight,
            )
        }
        label.layer.cornerRadius = badgeHeight / 2

        hostWindow?.accessibilityValue = "\(value) notifications"
    }

    /// Removes the label from its host window.
    func remove() {
        label?.removeFromSuperview()
        label = nil
        hostWindow = nil
        count = 0
    }
}
