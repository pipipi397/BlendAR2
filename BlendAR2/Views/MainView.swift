import SwiftUI
import FirebaseAuth

struct MainView: View {
    var body: some View {
        VStack {
            Text("ようこそ！")
                .font(.largeTitle)
                .padding()
            
            Button(action: {
                logout()
            }) {
                Text("ログアウト")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            print("ログアウトしました")
            
            // ログアウト後はログイン画面に遷移
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = UIHostingController(rootView: LoginView())
                window.makeKeyAndVisible()
                windowScene.windows.first?.rootViewController = window.rootViewController
            }
            
        } catch {
            print("ログアウトエラー: \(error.localizedDescription)")
        }
    }
}
