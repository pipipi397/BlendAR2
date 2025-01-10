import SwiftUI
import RealityKit
import CoreLocation

struct UploadView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var comment: String = ""
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var locationManager = LocationManager()

    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else {
                Text("画像を選択してください")
                    .padding()
            }

            TextField("コメントを入力", text: $comment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                isImagePickerPresented = true
            }) {
                Text("画像を選択")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                guard let image = selectedImage else {
                    print("画像が選択されていません")
                    return
                }

                guard let userLocation = locationManager.userLocation else {
                    print("位置情報が取得できません")
                    return
                }

                uploadPost(image: image, userLocation: userLocation, comment: comment)
            }) {
                Text("投稿する")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePickerView(image: $selectedImage)
        }
    }

    private func uploadPost(image: UIImage, userLocation: CLLocationCoordinate2D, comment: String) {
        PostManager.shared.uploadPost(image: image, userLocation: userLocation, comment: comment) { result in
            switch result {
            case .success:
                print("投稿が成功しました")
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print("投稿に失敗しました: \(error.localizedDescription)")
            }
        }
    }
}
