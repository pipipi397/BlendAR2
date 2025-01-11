import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @Binding var isLoginSuccessful: Bool  // ログイン成功のフラグ
    @Binding var isLoginMessageVisible: Bool  // ログイン中メッセージの表示状態
    @State private var navigateToSignUp = false  // 新規登録画面への遷移フラグ
    @State private var signUpLoginSuccess = false  // SignUpViewから受け取るためのState

    var body: some View {
        NavigationView { // NavigationViewを追加
            VStack(spacing: 20) {
                if isLoginMessageVisible {
                    Text("ログイン中です...")
                        .padding()
                        .foregroundColor(.blue)
                }

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

                // 新規登録ボタン
                Button(action: {
                    navigateToSignUp = true
                }) {
                    Text("新規登録")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)

                // 新規登録画面への遷移
                NavigationLink(
                    destination: SignUpView(isLoginSuccessful: $signUpLoginSuccess),
                    isActive: $navigateToSignUp // フラグで遷移
                ) {
                    EmptyView()
                }
            }
            .padding()
            .onChange(of: signUpLoginSuccess) { newValue in
                if newValue {
                    isLoginSuccessful = true  // 新規登録成功でMainViewへ
                }
            }
        }
    }

    private func login() {
        AuthManager.shared.login(email: email, password: password) { result in
            switch result {
            case .success:
                print("ログイン成功")
                isLoginSuccessful = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}
