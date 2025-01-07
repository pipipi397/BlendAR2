import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("表示名", text: $displayName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

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
                signUp()
            }) {
                Text("新規登録")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }

    // 新規登録処理
    func signUp() {
        SignUpManager.shared.signUp(email: email, password: password, displayName: displayName) { result in
            switch result {
            case .success:
                print("新規登録成功")
                // 新規登録後にメイン画面に遷移
            case .failure(let error):
                errorMessage = error.localizedDescription  // エラーメッセージを表示
            }
        }
    }
}
