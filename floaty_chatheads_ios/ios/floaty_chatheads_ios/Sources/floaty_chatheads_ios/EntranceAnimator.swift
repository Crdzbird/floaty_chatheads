import UIKit

/// Plays the configured entrance animation when an overlay window first
/// appears. Lives in its own file so the four animation styles can be
/// read/modified without scrolling past the plugin's lifecycle code.
@MainActor
enum EntranceAnimator {
    static func apply(
        to window: UIWindow,
        animation: EntranceAnimationMessage,
        screenWidth: CGFloat,
    ) {
        switch animation {
        case .none:
            window.alpha = 1
            window.makeKeyAndVisible()

        case .pop:
            window.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            window.alpha = 1
            window.makeKeyAndVisible()
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.8,
                options: [],
                animations: { window.transform = .identity },
                completion: nil,
            )

        case .slideFromEdge:
            let targetX = window.frame.origin.x
            window.frame.origin.x = screenWidth + window.frame.width
            window.alpha = 1
            window.makeKeyAndVisible()
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5,
                options: [],
                animations: { window.frame.origin.x = targetX },
                completion: nil,
            )

        case .fade:
            window.alpha = 0
            window.makeKeyAndVisible()
            UIView.animate(withDuration: 0.25) { window.alpha = 1 }
        }
    }
}
