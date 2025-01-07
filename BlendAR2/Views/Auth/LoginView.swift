import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    @ObservedObject private var authManager = AuthManager.shared

    var body: some View {
        VStack(spacing: 20) {
            TextField("メールアドレス", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("パスワード", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: {
                login()
            }) {
                Text("ログイン")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }

    // ログイン処理
    func login() {
        authManager.login(email: email, password: password) { result in
            switch result {
            case .success:
                print("ログイン成功")
                // ログイン成功後にメイン画面に遷移
                // ここで画面遷移処理を書く
            case .failure(let error):
                errorMessage = error.localizedDescription  // エラーメッセージを表示
            }
        }
    }
}
