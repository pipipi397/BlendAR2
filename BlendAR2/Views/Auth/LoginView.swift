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
                print("ログインボタンが押されました")
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

    private func login() {
        print("ログイン処理開始")
        AuthManager.shared.login(email: email, password: password) { result in
            switch result {
            case .success:
                print("ログイン成功")
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}
