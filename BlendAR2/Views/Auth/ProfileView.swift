import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var displayName: String = ""
    @State private var isEditing: Bool = false
    @State private var profileImage: UIImage?
    @State private var showImagePicker = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let user = authManager.currentUser {
                AsyncImage(url: URL(string: user.profileImageURL)) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                }
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .onTapGesture {
                    showImagePicker = true
                }
                .padding()

                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if isEditing {
                    TextField("表示名", text: $displayName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                } else {
                    Text(user.displayName)
                        .font(.title)
                        .padding()
                }
                
                Button(action: {
                    if isEditing {
                        updateProfile()
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "保存" : "プロフィールを編集")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            } else {
                Text("ユーザーデータがありません")
            }
        }
        .onAppear {
            if let user = authManager.currentUser {
                displayName = user.displayName
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(image: $profileImage)  // 画像選択ビュー
        }
    }
    
    // プロフィール更新処理
    func updateProfile() {
        guard let uid = authManager.currentUser?.uid else { return }

        // プロフィール画像が選択されている場合、画像をアップロードしてURLを取得
        if let profileImage = profileImage {
            ProfileManager.shared.uploadProfileImage(profileImage) { result in
                switch result {
                case .success(let imageURL):
                    updateUser(displayName: displayName, profileImageURL: imageURL)
                case .failure(let error):
                    errorMessage = "画像のアップロードに失敗: \(error.localizedDescription)"
                }
            }
        } else {
            updateUser(displayName: displayName, profileImageURL: nil)
        }
    }

    // Firestoreにプロフィール情報を更新
    func updateUser(displayName: String, profileImageURL: String?) {
        guard let uid = authManager.currentUser?.uid else { return }

        ProfileManager.shared.updateUserProfile(uid: uid, displayName: displayName, profileImageURL: profileImageURL) { result in
            switch result {
            case .success:
                print("プロフィールが更新されました")
            case .failure(let error):
                errorMessage = "更新に失敗: \(error.localizedDescription)"
            }
        }
    }
}
