import SwiftUI

struct LoginView: View {
    @State private var showLogin = false
    @State private var showSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("BlendAR2")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // ログインボタン
                Button(action: {
                    showLogin = true
                }) {
                    Text("ログイン")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .fullScreenCover(isPresented: $showLogin) {
                    LoginFormView()  // ログインフォーム画面に遷移
                }
                
                // 新規登録ボタン
                Button(action: {
                    showSignUp = true
                }) {
                    Text("新規登録")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .fullScreenCover(isPresented: $showSignUp) {
                    SignUpView()  // 新規登録画面に遷移
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
