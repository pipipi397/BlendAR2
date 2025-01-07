import UIKit
import SwiftUI
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        let contentView: AnyView
        
        // ログイン状態を確認
        if Auth.auth().currentUser != nil {
            // ログイン済みならメイン画面
            contentView = AnyView(MainView())
        } else {
            // 未ログインならログイン画面
            contentView = AnyView(LoginView())
        }
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
