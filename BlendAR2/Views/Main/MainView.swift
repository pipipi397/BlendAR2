import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Text("ようこそ！")
                .font(.largeTitle)
                .padding()
            
            Spacer()
            
            Button(action: {
                AuthManager.shared.logout()
            }) {
                Text("ログアウト")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}
