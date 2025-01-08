import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var isSignUpSuccessful = false
    @State private var showAlert = false
    @Binding var isLoginSuccessful: Bool

    var body: some View {
        VStack(spacing: 20) {
            TextField("メールアドレス", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("パスワード", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("パスワード確認", text: $confirmPassword)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: {
                signUp()
            }) {
                Text("新規登録")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("新規登録完了"),
                message: Text("アカウントの作成が完了しました。"),
                dismissButton: .default(Text("OK"), action: {
                    isSignUpSuccessful = true
                    isLoginSuccessful = true  // ログイン状態を維持
                })
            )
        }
        .background(
            NavigationLink(
                destination: MainView(),
                isActive: $isSignUpSuccessful,
                label: { EmptyView() }
            )
        )
    }

    private func signUp() {
        if password != confirmPassword {
            errorMessage = "パスワードが一致しません"
            return
        }

        AuthManager.shared.signUp(email: email, password: password) { result in
            switch result {
            case .success:
                print("新規登録成功")
                autoLogin()  // 登録成功後に自動ログイン
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }

    private func autoLogin() {
        AuthManager.shared.login(email: email, password: password) { result in
            switch result {
            case .success:
                showAlert = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}
