import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @ObservedObject private var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            if authManager.isLoggedIn {
                MainView()  // ログイン状態ならマップ画面へ
            } else {
                AuthView()  // 未ログインなら認証画面
            }
        }
        .onAppear {
            authManager.isLoggedIn = Auth.auth().currentUser != nil
        }
    }
}
