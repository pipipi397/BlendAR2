import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Text("ログイン")
                .font(.largeTitle)
                .padding()
            
            TextField("メールアドレス", text: $email)
                .padding()
                .autocapitalization(.none)
            
            SecureField("パスワード", text: $password)
                .padding()
            
            Button(action: {
                login()
            }) {
                Text("ログイン")
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
    
    // ログイン処理
    func login() {
        AuthManager.shared.login(email: email, password: password) { result in
            switch result {
            case .success:
                print("ログイン成功")
                
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
