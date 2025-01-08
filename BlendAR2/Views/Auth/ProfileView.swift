import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var username = "ユーザー名"
    @State private var bio = "自己紹介を入力"
    
    var body: some View {
        VStack {
            Text("プロフィール編集")
                .font(.largeTitle)
                .padding(.top)
            
            Form {
                Section(header: Text("名前")) {
                    TextField("ユーザー名", text: $username)
                }
                
                Section(header: Text("自己紹介")) {
                    TextField("自己紹介", text: $bio)
                }
            }
            .padding(.top)
            
            Button(action: {
                saveProfile()
            }) {
                Text("保存する")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
            
            Spacer()
        }
    }
    
    // プロフィール保存処理
    private func saveProfile() {
        // 保存処理（Firebase連携などを実装）
        print("プロフィールが保存されました")
        presentationMode.wrappedValue.dismiss()
    }
}
