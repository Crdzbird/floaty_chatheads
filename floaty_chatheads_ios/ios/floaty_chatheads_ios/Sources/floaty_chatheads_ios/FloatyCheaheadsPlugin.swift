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
    private var badgeCount: Int = 0
    private var currentChatHeadId: String = "default"

    // Config state
    private var currentSnapEdge: SnapEdgeMessage = .both
    private var currentSnapMargin: Double = 16.0
    private var currentPersistPosition: Bool = false
    private var currentEntranceAnimation: EntranceAnimationMessage = .fade
    private var currentTheme: ChatHeadThemeMessage?
    private var currentDebugMode: Bool = false

    // UI elements
    private var badgeLabel: UILabel?

    private var mainMessenger: FlutterBasicMessageChannel?
    private var overlayMessenger: FlutterBasicMessageChannel?

    // MARK: - Constants
    private static let messengerChannelName = "ni.devotion.floaty_head/messenger"
    private static let positionXKey = "floaty_chatheads_x"
    private static let positionYKey = "floaty_chatheads_y"

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
        applyBadgeCount(Int(count))
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
        contentSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        if isExpanded {
            var frame = window.frame
            frame.size = contentSize
            window.frame = frame
        }
    }

    func updateFlag(flag: OverlayFlagMessage) throws {
        guard let window = overlayWindow else { return }
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

    func getOverlayPosition() throws -> OverlayPositionMessage {
        guard let window = overlayWindow else {
            return OverlayPositionMessage(x: 0, y: 0)
        }
        return OverlayPositionMessage(
            x: Double(window.frame.origin.x),
            y: Double(window.frame.origin.y)
        )
    }

    func updateBadgeFromOverlay(count: Int64) throws {
        applyBadgeCount(Int(count))
    }

    func getDebugInfo() throws -> [String?: Any?] {
        return [
            "isOverlayActive": isOverlayActive,
            "isExpanded": isExpanded,
            "badgeCount": badgeCount,
            "windowX": overlayWindow?.frame.origin.x ?? 0,
            "windowY": overlayWindow?.frame.origin.y ?? 0,
            "windowWidth": overlayWindow?.frame.width ?? 0,
            "windowHeight": overlayWindow?.frame.height ?? 0,
            "snapEdge": "\(currentSnapEdge)",
            "snapMargin": currentSnapMargin,
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
        applyTheme(to: window, theme: config.theme)

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

        // Create badge label
        createBadgeLabel(on: window)

        // Entrance animation
        applyEntranceAnimation(to: window, animation: config.entranceAnimation)
    }

    private func destroyOverlayWindow() {
        let closedId = currentChatHeadId

        overlayMessenger?.setMessageHandler(nil)
        overlayMessenger = nil
        overlayFlutterApi = nil

        badgeLabel?.removeFromSuperview()
        badgeLabel = nil

        overlayWindow?.isHidden = true
        overlayWindow?.rootViewController = nil
        overlayWindow = nil
        overlayEngine?.destroyContext()
        overlayEngine = nil
        isOverlayActive = false
        isExpanded = false
        badgeCount = 0

        // Notify the main app that the chathead was closed.
        mainMessenger?.sendMessage([
            "__floaty__": "_floaty_closed",
            "_floaty_closed": ["id": closedId],
        ])
    }

    // MARK: - Entrance Animations

    private func applyEntranceAnimation(to window: UIWindow, animation: EntranceAnimationMessage) {
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
                animations: {
                    window.transform = .identity
                },
                completion: nil
            )

        case .slideFromEdge:
            let screenBounds = self.screenBounds
            let targetX = window.frame.origin.x
            window.frame.origin.x = screenBounds.width + window.frame.width
            window.alpha = 1
            window.makeKeyAndVisible()
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5,
                options: [],
                animations: {
                    window.frame.origin.x = targetX
                },
                completion: nil
            )

        case .fade:
            window.alpha = 0
            window.makeKeyAndVisible()
            UIView.animate(withDuration: 0.25) {
                window.alpha = 1
            }
        }
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

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
                window.frame.origin = origin
            },
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

    // MARK: - Badge Counter

    private func createBadgeLabel(on window: UIWindow) {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white
        label.backgroundColor = .red
        label.clipsToBounds = true
        label.isHidden = true

        // Apply theme colors if available
        if let theme = currentTheme {
            if let badgeColor = theme.badgeColor {
                label.backgroundColor = UIColor(argb: badgeColor)
            }
            if let badgeTextColor = theme.badgeTextColor {
                label.textColor = UIColor(argb: badgeTextColor)
            }
        }

        let badgeSize: CGFloat = 18
        label.frame = CGRect(
            x: window.frame.width - badgeSize / 2,
            y: -badgeSize / 2,
            width: badgeSize,
            height: badgeSize
        )
        label.layer.cornerRadius = badgeSize / 2

        window.addSubview(label)
        badgeLabel = label
    }

    private func applyBadgeCount(_ count: Int) {
        badgeCount = count
        guard let label = badgeLabel else { return }

        if count <= 0 {
            label.isHidden = true
            overlayWindow?.accessibilityValue = nil
        } else {
            label.isHidden = false
            let displayText = count > 99 ? "99+" : "\(count)"
            label.text = displayText

            // Resize badge to fit text
            let textWidth = (displayText as NSString).size(withAttributes: [.font: label.font!]).width
            let badgeWidth = max(18, textWidth + 8)
            let badgeHeight: CGFloat = 18
            if let window = overlayWindow {
                label.frame = CGRect(
                    x: window.frame.width - badgeWidth / 2,
                    y: -badgeHeight / 2,
                    width: badgeWidth,
                    height: badgeHeight
                )
            }
            label.layer.cornerRadius = badgeHeight / 2

            overlayWindow?.accessibilityValue = "\(count) notifications"
        }
    }

    // MARK: - Theming

    private func applyTheme(to window: UIWindow, theme: ChatHeadThemeMessage?) {
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

    // MARK: - Expand / Collapse

    private func performExpand() {
        guard let window = overlayWindow, !isExpanded else { return }
        isExpanded = true

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
                window.frame.size = self.contentSize
            },
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

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
                window.frame.size = self.bubbleSize
            },
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.overlayFlutterApi?.onChatHeadCollapsed(id: self.currentChatHeadId) { _ in }
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            }
        )
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
            overlayFlutterApi?.onChatHeadDragStart(
                id: currentChatHeadId,
                x: Double(window.frame.origin.x),
                y: Double(window.frame.origin.y)
            ) { _ in }
        case .changed:
            let newX = panOrigin.x + translation.x
            let newY = panOrigin.y + translation.y
            window.frame.origin = CGPoint(x: newX, y: newY)
        case .ended, .cancelled:
            snapToEdge(window: window)
            overlayFlutterApi?.onChatHeadDragEnd(
                id: currentChatHeadId,
                x: Double(window.frame.origin.x),
                y: Double(window.frame.origin.y)
            ) { _ in }
        default:
            break
        }
    }
}

// MARK: - UIColor ARGB Extension

private extension UIColor {
    convenience init(argb: Int64) {
        let a = CGFloat((argb >> 24) & 0xFF) / 255.0
        let r = CGFloat((argb >> 16) & 0xFF) / 255.0
        let g = CGFloat((argb >> 8) & 0xFF) / 255.0
        let b = CGFloat(argb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
