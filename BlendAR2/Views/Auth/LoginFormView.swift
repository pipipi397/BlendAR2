import SwiftUI

struct LoginFormView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("ログイン")
                .font(.title)
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
                AuthManager.shared.login(email: email, password: password) { result in
                    switch result {
                    case .success:
                        print("ログイン成功")
                        presentationMode.wrappedValue.dismiss()  // ログイン成功後は画面を閉じる
                    case .failure(let error):
                        errorMessage = "ログイン失敗: \(error.localizedDescription)"
                    }
                }
            }) {
                Text("ログイン")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

