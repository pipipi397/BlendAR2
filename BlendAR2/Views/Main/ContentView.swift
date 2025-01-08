import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isLoggedIn = false  // ログイン状態を保持
    @State private var isLoginSuccessful = false  // ログイン成功フラグ
    @State private var isLoginMessageVisible = false  // ログイン中メッセージ

    var body: some View {
        VStack {
            if isLoggedIn || isLoginSuccessful {  // ログイン成功時にMainViewを表示
                MainView()  // ログイン成功したらMainView
            } else {
                LoginView(isLoginSuccessful: $isLoginSuccessful, isLoginMessageVisible: $isLoginMessageVisible)  // ログインしていない場合はLoginView
            }
        }
        .onAppear {
            checkLoginStatus()  // ログイン状態の確認
        }
    }

    // ログイン状態の確認
    private func checkLoginStatus() {
        if let user = Auth.auth().currentUser {
            isLoggedIn = true  // ログインしている場合
            isLoginMessageVisible = true  // ログイン中メッセージを表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                isLoginMessageVisible = false
            }
        } else {
            isLoggedIn = false  // ログインしていない場合
        }
    }
}
