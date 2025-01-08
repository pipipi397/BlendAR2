import SwiftUI
import Firebase
import FirebaseStorage

struct UploadView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isUploading = false
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .cornerRadius(10)
            } else {
                Text("画像を選択してください")
                    .padding()
            }

            Button(action: {
                isImagePickerPresented = true
            }) {
                Text("画像を選択")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Button(action: {
                if let image = selectedImage {
                    uploadImageToFirebase(image: image)
                }
            }) {
                Text("投稿する")
                    .padding()
                    .background(isUploading ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(selectedImage == nil || isUploading)
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePickerView(image: $selectedImage)
        }
    }

    // Firebase Storageへの画像アップロード
    private func uploadImageToFirebase(image: UIImage) {
        isUploading = true
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let storageRef = Storage.storage().reference().child("posts/\(UUID().uuidString).jpg")

        storageRef.putData(imageData, metadata: nil) { _, error in
            isUploading = false
            if let error = error {
                print("画像のアップロードに失敗しました: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("ダウンロードURLの取得に失敗しました: \(error.localizedDescription)")
                } else if let downloadURL = url {
                    savePostData(imageURL: downloadURL.absoluteString)
                }
            }
        }
    }

    // Firestoreに投稿データを保存
    private func savePostData(imageURL: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let post = [
            "imageURL": imageURL,
            "latitude": 35.681236,  // 仮の値 (東京駅)
            "longitude": 139.767125,
            "userID": userID,
            "timestamp": Timestamp(date: Date())
        ] as [String : Any]

        Firestore.firestore().collection("posts").addDocument(data: post) { error in
            if let error = error {
                print("投稿データの保存に失敗しました: \(error.localizedDescription)")
            } else {
                print("投稿が完了しました")
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
