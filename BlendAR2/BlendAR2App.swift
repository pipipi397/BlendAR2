import SwiftUI
import FirebaseCore

@main
struct BlendAR2App: App {
    @StateObject private var authManager = AuthManager.shared

    init() {
        // Firebaseの初期設定
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                MainView()  // ログイン状態ならMainView
            } else {
                LoginView()  // 未ログインならLoginView
            }
        }
    }
}
