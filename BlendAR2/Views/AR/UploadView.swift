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
                    isUploading = true
                    PostManager.shared.uploadImage(image) { result in
                        isUploading = false
                        switch result {
                        case .success(let imageURL):
                            print("アップロード成功: \(imageURL)")
                            savePostData(imageURL: imageURL)
                        case .failure(let error):
                            print("アップロード失敗: \(error.localizedDescription)")
                        }
                    }
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

    private func savePostData(imageURL: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let post = [
            "imageURL": imageURL,
            "latitude": 35.681236,  // 仮の位置情報
            "longitude": 139.767125,
            "userID": userID,
            "timestamp": Timestamp(date: Date())
        ] as [String: Any]

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
