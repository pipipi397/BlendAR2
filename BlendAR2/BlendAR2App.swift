import SwiftUI
import Firebase

@main
struct BlendAR2App: App {
    // Firebaseの初期化
    init() {
        FirebaseApp.configure()  // Firebaseの初期化
    }

    var body: some Scene {
        WindowGroup {
            ContentView()  // ログイン状態に応じて表示する画面
        }
    }
}
