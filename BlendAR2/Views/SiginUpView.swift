import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var userID = ""
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Text("新規登録")
                .font(.largeTitle)
                .padding()
            
            TextField("メールアドレス", text: $email)
                .padding()
                .autocapitalization(.none)
            
            SecureField("パスワード", text: $password)
                .padding()
            
            TextField("ユーザーID", text: $userID)
                .padding()
                .autocapitalization(.none)
            
            Button(action: {
                signUp()
            }) {
                Text("登録")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
    
    // 登録処理
    func signUp() {
        AuthManager.shared.signUp(email: email, password: password, userID: userID) { result in
            switch result {
            case .success:
                print("登録成功")
                
                // メイン画面へ遷移
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    let window = UIWindow(windowScene: windowScene)
                    window.rootViewController = UIHostingController(rootView: MainView())
                    window.makeKeyAndVisible()
                    windowScene.windows.first?.rootViewController = window.rootViewController
                }
                
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}
