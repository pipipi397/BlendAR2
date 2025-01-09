import SwiftUI

struct UploadView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isARViewPresented = false

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

            if selectedImage != nil {
                Button(action: {
                    isARViewPresented = true
                }) {
                    Text("AR表示")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePickerView(image: $selectedImage)
        }
        .sheet(isPresented: $isARViewPresented) {
            ARPostViewContainer()
        }
    }
}
