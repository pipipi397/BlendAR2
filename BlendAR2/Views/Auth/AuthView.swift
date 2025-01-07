import SwiftUI

struct AuthView: View {
    var body: some View {
        VStack {
            NavigationLink(destination: LoginView()) {
                Text("ログイン")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            NavigationLink(destination: SignUpView()) {
                Text("新規登録")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}

