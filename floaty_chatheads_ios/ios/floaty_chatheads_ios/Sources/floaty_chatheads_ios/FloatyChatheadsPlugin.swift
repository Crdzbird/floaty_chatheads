@preconcurrency import Flutter
import UIKit

@MainActor
public final class FloatyChatheadsPlugin: NSObject, FlutterPlugin, @preconcurrency FloatyHostApi, @preconcurrency FloatyOverlayHostApi {

    private var overlayWindow: UIWindow?
    private var overlayEngine: FlutterEngine?
    private var overlayFlutterApi: FloatyOverlayFlutterApi?
    private var panOrigin: CGPoint = .zero
    private var contentSize: CGSize = CGSize(width: 300, height: 400)
    private let bubbleSize = CGSize(width: 64, height: 64)
    private var isOverlayActive = false
    private var isExpanded = false
    private var currentChatHeadId: String = "default"

    // Config state
    private var currentSnapEdge: SnapEdgeMessage = .both
    private var currentSnapMargin: Double = 16.0
    private var currentPersistPosition: Bool = false
    private var currentEntranceAnimation: EntranceAnimationMessage = .fade
    private var currentTheme: ChatHeadThemeMessage?
    private var currentDebugMode: Bool = false
    private var currentPanelAnchor: PanelAnchorMessage = .below

    /// Anchor resolved once per expand — AUTO never flip-flops mid-animation.
    private var effectiveAnchor: PanelAnchorMessage = .below

    /// Bubble origin captured when the panel expands so collapse restores
    /// the bubble to its pre-expand spot. Cleared when the user drags the
    /// expanded panel — collapsing then keeps the new position.
    private var collapsedOrigin: CGPoint?

    // Badge label is managed by [BadgeView].
    private let badge = BadgeView()

    private var mainMessenger: FlutterBasicMessageChannel?
    private var overlayMessenger: FlutterBasicMessageChannel?

    // MARK: - Constants
    private static let messengerChannelName = "ni.devotion.floaty_head/messenger"
    private static let positionXKey = "floaty_chatheads_x"
    private static let positionYKey = "floaty_chatheads_y"
    private static let panelGap: CGFloat = 8

    // Using nonisolated to satisfy FlutterPlugin's static registration
    // requirement. The instance methods are all @MainActor-isolated.
    nonisolated public static func register(with registrar: FlutterPluginRegistrar) {
        MainActor.assumeIsolated {
            let instance = FloatyChatheadsPlugin()
            FloatyHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)

            instance.mainMessenger = FlutterBasicMessageChannel(
                name: messengerChannelName,
                binaryMessenger: registrar.messenger(),
                codec: FlutterJSONMessageCodec.sharedInstance()
            )
            instance.mainMessenger?.setMessageHandler { [weak instance] message, reply in
                MainActor.assumeIsolated {
                    instance?.overlayMessenger?.sendMessage(message, reply: reply)
                }
            }
        }
    }

    // MARK: - FloatyHostApi

    func checkPermission() throws -> Bool {
        return true
    }

    func requestPermission(completion: @escaping (Result<Bool, any Error>) -> Void) {
        completion(.success(true))
    }

    func showChatHead(config: ChatHeadConfig, completion: @escaping (Result<Void, any Error>) -> Void) {
        createOverlayWindow(config: config)
        completion(.success(()))
    }

    func closeChatHead() throws {
        destroyOverlayWindow()
    }

    func isChatHeadActive() throws -> Bool {
        return isOverlayActive
    }

    func addChatHead(config: AddChatHeadConfig, completion: @escaping (Result<Void, any Error>) -> Void) {
        // Multi-chathead is not supported on iOS.
        // The overlay shows a single bubble managed by the UIWindow.
        completion(.success(()))
    }

    func removeChatHead(id: String) throws {
        // Multi-chathead is not supported on iOS.
        // Use closeChatHead() to remove the single overlay.
    }

    func updateBadge(count: Int64) throws {
        badge.setCount(Int(count))
    }

    func expandChatHead() throws {
        performExpand()
    }

    func collapseChatHead() throws {
        performCollapse()
    }

    func updateChatHeadIcon(id: String, rgbaBytes: FlutterStandardTypedData, width: Int64, height: Int64) throws {
        // No-op on iOS — the chathead bubble is a FlutterViewController,
        // so widget-based icons render directly via the overlay engine.
    }

    // MARK: - FloatyOverlayHostApi

    func resizeContent(width: Int64, height: Int64) throws {
        guard let window = overlayWindow else { return }
        let oldHeight = window.frame.height
        contentSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        if isExpanded {
            var frame = window.frame
            if effectiveAnchor == .above {
                // Keep the bottom edge glued to the bubble line.
                frame.origin.y += oldHeight - contentSize.height
            }
            frame.size = contentSize
            let screen = screenBounds
            frame.origin.x = min(max(frame.origin.x, 0), max(screen.width - frame.width, 0))
            frame.origin.y = min(max(frame.origin.y, 0), max(screen.height - frame.height, 0))
            window.frame = frame
        }
    }

    func updateFlag(flagIndex: Int64) throws {
        guard let window = overlayWindow,
              let flag = OverlayFlagMessage(rawValue: Int(flagIndex)) else { return }
        switch flag {
        case .clickThrough:
            window.isUserInteractionEnabled = false
        case .focusPointer, .defaultFlag:
            window.isUserInteractionEnabled = true
        }
    }

    func closeOverlay() throws {
        destroyOverlayWindow()
    }

    func getOverlayPosition() throws -> [String?: Any?] {
        let origin = windowPosition()
        return ["x": Double(origin.x), "y": Double(origin.y)]
    }

    /// Current window origin (0,0 when no overlay).
    private func windowPosition() -> CGPoint {
        return overlayWindow?.frame.origin ?? .zero
    }

    func updateBadgeFromOverlay(count: Int64) throws {
        badge.setCount(Int(count))
    }

    func getDebugInfo() throws -> [String?: Any?] {
        return [
            "isOverlayActive": isOverlayActive,
            "isExpanded": isExpanded,
            "badgeCount": badge.count,
            "windowX": overlayWindow?.frame.origin.x ?? 0,
            "windowY": overlayWindow?.frame.origin.y ?? 0,
            "windowWidth": overlayWindow?.frame.width ?? 0,
            "windowHeight": overlayWindow?.frame.height ?? 0,
            "snapEdge": "\(currentSnapEdge)",
            "snapMargin": currentSnapMargin,
            "panelAnchor": "\(currentPanelAnchor)",
            "persistPosition": currentPersistPosition,
        ]
    }

    private var screenBounds: CGRect {
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first {
            return scene.screen.bounds
        }
        return UIScreen.main.bounds
    }

    // MARK: - Private — Window Lifecycle

    private func createOverlayWindow(config: ChatHeadConfig) {
        destroyOverlayWindow()

        // Store config
        currentSnapEdge = config.snapEdge
        currentSnapMargin = config.snapMargin
        currentPersistPosition = config.persistPosition
        currentEntranceAnimation = config.entranceAnimation
        currentTheme = config.theme
        currentDebugMode = config.debugMode
        currentPanelAnchor = config.panelAnchor

        let engine = FlutterEngine(name: "floaty_chatheads_overlay")
        let started = engine.run(withEntrypoint: config.entryPoint)
        if !started {
            print("[FloatyChatheads] Failed to start overlay engine with entrypoint: \(config.entryPoint)")
        }
        overlayEngine = engine

        // Reset to defaults before applying config so previous session
        // dimensions don't leak when the new config omits width/height.
        contentSize = CGSize(width: 300, height: 400)
        if let w = config.contentWidth { contentSize.width = CGFloat(w) }
        if let h = config.contentHeight { contentSize.height = CGFloat(h) }

        let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        flutterVC.view.backgroundColor = .clear

        FloatyOverlayHostApiSetup.setUp(binaryMessenger: engine.binaryMessenger, api: self)

        overlayFlutterApi = FloatyOverlayFlutterApi(binaryMessenger: engine.binaryMessenger)

        overlayMessenger = FlutterBasicMessageChannel(
            name: Self.messengerChannelName,
            binaryMessenger: engine.binaryMessenger,
            codec: FlutterJSONMessageCodec.sharedInstance()
        )
        overlayMessenger?.setMessageHandler { [weak self] message, reply in
            MainActor.assumeIsolated {
                self?.mainMessenger?.sendMessage(message, reply: reply)
            }
        }

        // Deliver theme palette to overlay isolate
        if let palette = config.theme?.overlayPalette {
            let paletteDict: [String: Any] = ["__floaty__": "_floaty_theme", "_floaty_theme": palette]
            overlayMessenger?.sendMessage(paletteDict, reply: nil)
        }

        let screenBounds = self.screenBounds

        // Determine initial position
        var x: CGFloat
        var y: CGFloat

        if currentPersistPosition, let savedX = UserDefaults.standard.object(forKey: FloatyChatheadsPlugin.positionXKey) as? CGFloat,
           let savedY = UserDefaults.standard.object(forKey: FloatyChatheadsPlugin.positionYKey) as? CGFloat {
            x = savedX
            y = savedY
        } else {
            x = screenBounds.width - contentSize.width - CGFloat(currentSnapMargin)
            y = 80
        }

        let window: UIWindow
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first {
            window = UIWindow(windowScene: scene)
        } else {
            window = UIWindow()
        }

        window.frame = CGRect(x: x, y: y, width: contentSize.width, height: contentSize.height)
        window.windowLevel = .alert + 1
        window.rootViewController = flutterVC
        window.backgroundColor = .clear
        window.clipsToBounds = false
        window.layer.cornerRadius = 16

        // Apply theming
        OverlayThemer.apply(to: window, theme: config.theme)

        if config.enableDrag {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            window.addGestureRecognizer(pan)
        }

        // VoiceOver accessibility
        window.isAccessibilityElement = true
        window.accessibilityLabel = "Chat bubble"
        window.accessibilityTraits = .button

        overlayWindow = window
        isOverlayActive = true

        // Set badge theme colors before install so the label picks them up.
        if let theme = config.theme {
            if let bg = theme.badgeColor { badge.backgroundColor = UIColor(argb: bg) }
            if let tc = theme.badgeTextColor { badge.textColor = UIColor(argb: tc) }
        }
        badge.install(on: window)

        EntranceAnimator.apply(
            to: window,
            animation: config.entranceAnimation,
            screenWidth: screenBounds.width,
        )
    }

    private func destroyOverlayWindow() {
        let closedId = currentChatHeadId

        overlayMessenger?.setMessageHandler(nil)
        overlayMessenger = nil
        overlayFlutterApi = nil

        badge.remove()

        overlayWindow?.isHidden = true
        overlayWindow?.rootViewController = nil
        overlayWindow = nil
        overlayEngine?.destroyContext()
        overlayEngine = nil
        isOverlayActive = false
        isExpanded = false

        // Notify the main app that the chathead was closed.
        mainMessenger?.sendMessage([
            "__floaty__": "_floaty_closed",
            "_floaty_closed": ["id": closedId],
        ])
    }

    // MARK: - Snap-to-Edge

    private func snapToEdge(window: UIWindow) {
        let screen = screenBounds
        let margin = CGFloat(currentSnapMargin)
        var origin = window.frame.origin

        // Bounds clamping
        origin.y = max(0, min(origin.y, screen.height - window.frame.height))

        switch currentSnapEdge {
        case .both:
            let midX = origin.x + window.frame.width / 2
            if midX < screen.width / 2 {
                origin.x = margin
            } else {
                origin.x = screen.width - window.frame.width - margin
            }

        case .left:
            origin.x = margin

        case .right:
            origin.x = screen.width - window.frame.width - margin

        case .none:
            origin.x = max(0, min(origin.x, screen.width - window.frame.width))
        }

        springAnimate(
            damping: 0.7,
            animations: { window.frame.origin = origin },
            completion: { [weak self] _ in
                guard let self = self else { return }
                if self.currentPersistPosition {
                    self.savePosition(origin)
                }
            }
        )
    }

    // MARK: - Position Persistence

    private func savePosition(_ origin: CGPoint) {
        UserDefaults.standard.set(origin.x, forKey: FloatyChatheadsPlugin.positionXKey)
        UserDefaults.standard.set(origin.y, forKey: FloatyChatheadsPlugin.positionYKey)
    }

    // MARK: - Animation Helper

    /// Shared spring animation for expand, collapse, and edge snapping.
    private func springAnimate(
        damping: CGFloat = 0.8,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: damping,
            initialSpringVelocity: 0.5,
            options: [],
            animations: animations,
            completion: completion
        )
    }

    // MARK: - Expand / Collapse

    private func performExpand() {
        guard let window = overlayWindow, !isExpanded else { return }
        isExpanded = true

        // The bubble occupies the window's top-left at bubbleSize —
        // deterministic even in the initial content-sized window state.
        let bubbleFrame = CGRect(origin: window.frame.origin, size: bubbleSize)
        collapsedOrigin = window.frame.origin
        effectiveAnchor = resolveAnchor(forBubble: bubbleFrame)
        let target = anchoredPanelFrame(forBubble: bubbleFrame)

        springAnimate(
            animations: { window.frame = target },
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.overlayFlutterApi?.onChatHeadExpanded(id: self.currentChatHeadId) { _ in }
                UIAccessibility.post(notification: .screenChanged, argument: window)
            }
        )
    }

    private func performCollapse() {
        guard let window = overlayWindow, isExpanded else { return }
        isExpanded = false

        let origin = collapsedOrigin ?? window.frame.origin
        collapsedOrigin = nil

        springAnimate(
            animations: { window.frame = CGRect(origin: origin, size: self.bubbleSize) },
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.overlayFlutterApi?.onChatHeadCollapsed(id: self.currentChatHeadId) { _ in }
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            }
        )
    }

    /// Resolves the configured anchor for this expand: AUTO picks below
    /// when the panel fits under the bubble, otherwise above.
    private func resolveAnchor(forBubble bubbleFrame: CGRect) -> PanelAnchorMessage {
        guard currentPanelAnchor == .auto else { return currentPanelAnchor }
        let fitsBelow =
            bubbleFrame.maxY + Self.panelGap + contentSize.height <= screenBounds.height
        return fitsBelow ? .below : .above
    }

    /// Panel frame glued to the bubble on the [effectiveAnchor] side,
    /// clamped so the panel never leaves the screen.
    private func anchoredPanelFrame(forBubble bubbleFrame: CGRect) -> CGRect {
        let screen = screenBounds
        let rawY: CGFloat
        switch effectiveAnchor {
        case .above:
            rawY = bubbleFrame.minY - Self.panelGap - contentSize.height
        case .below, .auto:
            rawY = bubbleFrame.maxY + Self.panelGap
        }
        // Panel right edge follows the bubble's right edge (matches the
        // Android implementation), clamped on-screen.
        let x = min(max(bubbleFrame.maxX - contentSize.width, 0), max(screen.width - contentSize.width, 0))
        let y = min(max(rawY, 0), max(screen.height - contentSize.height, 0))
        return CGRect(x: x, y: y, width: contentSize.width, height: contentSize.height)
    }

    // MARK: - Pan Gesture (Drag)

    // `nonisolated` so the ObjC gesture-action dispatch calls this
    // synchronously — avoids a MainActor executor hop that would
    // cause visible lag / freezing during drag.
    @objc nonisolated private func handlePan(_ gesture: UIPanGestureRecognizer) {
        MainActor.assumeIsolated {
            self.handlePanOnMain(gesture)
        }
    }

    private func handlePanOnMain(_ gesture: UIPanGestureRecognizer) {
        guard let window = overlayWindow else { return }
        let translation = gesture.translation(in: window)

        switch gesture.state {
        case .began:
            panOrigin = window.frame.origin
            let pos = windowPosition()
            overlayFlutterApi?.onChatHeadDragStart(id: currentChatHeadId, x: pos.x, y: pos.y) { _ in }
        case .changed:
            let newX = panOrigin.x + translation.x
            let newY = panOrigin.y + translation.y
            window.frame.origin = CGPoint(x: newX, y: newY)
            // The user moved the expanded panel deliberately — collapsing
            // should keep the new spot, not restore the pre-expand one.
            if isExpanded { collapsedOrigin = nil }
        case .ended, .cancelled:
            snapToEdge(window: window)
            let pos = windowPosition()
            overlayFlutterApi?.onChatHeadDragEnd(id: currentChatHeadId, x: pos.x, y: pos.y) { _ in }
        default:
            break
        }
    }
}

