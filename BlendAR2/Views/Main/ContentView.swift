import SwiftUI
import FirebaseAuth  // FirebaseAuthをインポート

struct ContentView: View {
    @ObservedObject private var authManager = AuthManager.shared

    var body: some View {
        Group {
            if authManager.isLoggedIn {
                // ログインしている場合はメイン画面を表示
                MainView()  // メイン画面（ログイン後の画面）
            } else {
                // ログインしていない場合はログイン画面を表示
                LoginView()  // ログイン画面
            }
        }
        .onAppear {
            // ログイン状態を確認
            authManager.isLoggedIn = Auth.auth().currentUser != nil
        }
    }
}
