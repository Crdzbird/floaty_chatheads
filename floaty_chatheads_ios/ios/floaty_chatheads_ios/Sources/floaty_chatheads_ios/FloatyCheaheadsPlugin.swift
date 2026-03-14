@preconcurrency import Flutter
import UIKit

public final class FloatyChatheadsPlugin: NSObject, @unchecked Sendable, FlutterPlugin, FloatyHostApi, FloatyOverlayHostApi {

    private var registrar: FlutterPluginRegistrar?
    private var overlayWindow: UIWindow?
    private var overlayEngine: FlutterEngine?
    private var overlayFlutterApi: FloatyOverlayFlutterApi?
    private var panOrigin: CGPoint = .zero
    private var contentSize: CGSize = CGSize(width: 300, height: 400)
    private var isOverlayActive = false

    private var mainMessenger: FlutterBasicMessageChannel?
    private var overlayMessenger: FlutterBasicMessageChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FloatyChatheadsPlugin()
        instance.registrar = registrar
        FloatyHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)

        instance.mainMessenger = FlutterBasicMessageChannel(
            name: "ni.devotion.floaty_head/messenger",
            binaryMessenger: registrar.messenger(),
            codec: FlutterJSONMessageCodec.sharedInstance()
        )
        instance.mainMessenger?.setMessageHandler { [weak instance] message, reply in
            instance?.overlayMessenger?.sendMessage(message, reply: reply)
        }
    }

    // MARK: - FloatyHostApi

    func checkPermission() throws -> Bool {
        return true
    }

    func requestPermission(completion: @escaping (Result<Bool, any Error>) -> Void) {
        completion(.success(true))
    }

    func showChatHead(config: ChatHeadConfig) throws {
        let cfg = config
        DispatchQueue.main.async {
            self.createOverlayWindow(config: cfg)
        }
    }

    func closeChatHead() throws {
        DispatchQueue.main.async {
            self.destroyOverlayWindow()
        }
    }

    func isChatHeadActive() throws -> Bool {
        return isOverlayActive
    }

    func addChatHead(config: AddChatHeadConfig) throws {
        overlayFlutterApi?.onChatHeadTapped(id: config.id) { _ in }
    }

    func removeChatHead(id: String) throws {
        overlayFlutterApi?.onChatHeadClosed(id: id) { _ in }
    }

    // MARK: - FloatyOverlayHostApi

    func resizeContent(width: Int64, height: Int64) throws {
        let w = width
        let h = height
        DispatchQueue.main.async {
            guard let window = self.overlayWindow else { return }
            self.contentSize = CGSize(width: CGFloat(w), height: CGFloat(h))
            var frame = window.frame
            frame.size = self.contentSize
            window.frame = frame
        }
    }

    func updateFlag(flag: OverlayFlagMessage) throws {
        let f = flag
        DispatchQueue.main.async {
            guard let window = self.overlayWindow else { return }
            switch f {
            case .clickThrough:
                window.isUserInteractionEnabled = false
            case .focusPointer, .defaultFlag:
                window.isUserInteractionEnabled = true
            }
        }
    }

    func closeOverlay() throws {
        DispatchQueue.main.async {
            self.destroyOverlayWindow()
        }
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

    // MARK: - Private

    private func createOverlayWindow(config: ChatHeadConfig) {
        destroyOverlayWindow()

        let engine = FlutterEngine(name: "floaty_chatheads_overlay")
        engine.run(withEntrypoint: config.entryPoint)
        overlayEngine = engine

        if let w = config.contentWidth { contentSize.width = CGFloat(w) }
        if let h = config.contentHeight { contentSize.height = CGFloat(h) }

        let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        flutterVC.view.backgroundColor = .clear

        FloatyOverlayHostApiSetup.setUp(binaryMessenger: engine.binaryMessenger, api: self)

        overlayFlutterApi = FloatyOverlayFlutterApi(binaryMessenger: engine.binaryMessenger)

        overlayMessenger = FlutterBasicMessageChannel(
            name: "ni.devotion.floaty_head/messenger",
            binaryMessenger: engine.binaryMessenger,
            codec: FlutterJSONMessageCodec.sharedInstance()
        )
        overlayMessenger?.setMessageHandler { [weak self] message, reply in
            self?.mainMessenger?.sendMessage(message, reply: reply)
        }

        let screenBounds = UIScreen.main.bounds
        let x = screenBounds.width - contentSize.width - 16
        let y: CGFloat = 80

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
        window.clipsToBounds = true
        window.layer.cornerRadius = 16

        if config.enableDrag {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            window.addGestureRecognizer(pan)
        }

        window.makeKeyAndVisible()
        overlayWindow = window
        isOverlayActive = true

        UIView.animate(withDuration: 0.25) {
            window.alpha = 1
        }
    }

    private func destroyOverlayWindow() {
        overlayMessenger?.setMessageHandler(nil)
        overlayMessenger = nil
        overlayFlutterApi = nil

        overlayWindow?.isHidden = true
        overlayWindow?.rootViewController = nil
        overlayWindow = nil
        overlayEngine?.destroyContext()
        overlayEngine = nil
        isOverlayActive = false
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let window = overlayWindow else { return }
        let translation = gesture.translation(in: window)

        switch gesture.state {
        case .began:
            panOrigin = window.frame.origin
        case .changed:
            let newX = panOrigin.x + translation.x
            let newY = panOrigin.y + translation.y
            window.frame.origin = CGPoint(x: newX, y: newY)
        case .ended, .cancelled:
            let screen = UIScreen.main.bounds
            var origin = window.frame.origin
            origin.x = max(0, min(origin.x, screen.width - window.frame.width))
            origin.y = max(0, min(origin.y, screen.height - window.frame.height))
            UIView.animate(withDuration: 0.2) {
                window.frame.origin = origin
            }
        default:
            break
        }
    }
}
