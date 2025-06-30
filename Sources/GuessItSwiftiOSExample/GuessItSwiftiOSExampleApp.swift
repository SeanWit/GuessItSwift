import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
@main
struct GuessItSwiftiOSExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Fallback for older iOS versions
#if os(iOS)
@available(iOS 13.0, *)
struct SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let contentView = ContentView()

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
#endif 