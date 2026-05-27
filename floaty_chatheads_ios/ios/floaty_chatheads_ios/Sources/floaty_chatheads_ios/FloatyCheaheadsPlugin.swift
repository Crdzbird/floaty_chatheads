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

    // Badge label is managed by [BadgeView].
    private let badge = BadgeView()

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

