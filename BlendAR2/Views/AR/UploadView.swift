import SwiftUI
import PhotosUI

struct UploadView: View {
    @State private var selectedImage: UIImage?
    @State private var showARView = false
    
    var body: some View {
        VStack {
            Text("画像を選択してください")
                .font(.title2)
            
            PhotosPicker(selection: .constant(nil), matching: .images) {
                Text("画像を選択")
                    .foregroundColor(.blue)
            }
            .onChange(of: selectedImage) { _ in
                if selectedImage != nil {
                    showARView.toggle()
                }
            }
        }
        .sheet(isPresented: $showARView) {
            ARPostView(image: selectedImage!)
        }
    }
}
