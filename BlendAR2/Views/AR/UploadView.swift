import SwiftUI
import Firebase
import FirebaseStorage
import CoreLocation

struct UploadView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isUploading = false
    @State private var currentLocation: CLLocationCoordinate2D?
    @State private var showError = false
    @State private var errorMessage = ""
    
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
                if let image = selectedImage, let location = currentLocation {
                    isUploading = true
                    PostManager.shared.uploadImage(image) { result in
                        switch result {
                        case .success(let imageURL):
                            PostManager.shared.savePost(imageURL: imageURL, location: location) { saveResult in
                                isUploading = false
                                switch saveResult {
                                case .success:
                                    presentationMode.wrappedValue.dismiss()
                                case .failure(let error):
                                    showError(error: error.localizedDescription)
                                }
                            }
                        case .failure(let error):
                            isUploading = false
                            showError(error: error.localizedDescription)
                        }
                    }
                } else {
                    showError(error: "位置情報が取得できませんでした")
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
        .onAppear {
            fetchCurrentLocation()
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("エラー"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    // 現在地の取得
    private func fetchCurrentLocation() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        if let location = locationManager.location {
            currentLocation = location.coordinate
        }
    }

    // エラー表示
    private func showError(error: String) {
        errorMessage = error
        showError = true
    }
}
