import SwiftUI

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Text("新規登録")
                .font(.largeTitle)
                .padding(.bottom, 40)
            
            TextField("メールアドレス", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("パスワード", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                AuthManager.shared.signUp(email: email, password: password) { result in
                    switch result {
                    case .success:
                        print("新規登録成功")
                    case .failure(let error):
                        errorMessage = "新規登録失敗: \(error.localizedDescription)"
                    }
                }
            }) {
                Text("新規登録")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}
