import SwiftUI
import RealityKit
import ARKit
import PhotosUI

struct ARPostView: View {
    @State private var arView = ARView(frame: .zero)
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        ZStack {
            ARViewContainer(arView: $arView)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Button(action: {
                    showImagePicker = true
                }) {
                    Text("画像を選択する")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(image: $selectedImage)
        }
        .onChange(of: selectedImage) {
            if let image = selectedImage {
                addImageToARView(image)
            }
        }
        
    }
    
    func addImageToARView(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let texture: TextureResource?
        if #available(iOS 18.0, *) {
            texture = try? TextureResource(image: cgImage, options: .init(semantic: .color))
        } else {
            texture = try? TextureResource.generate(from: cgImage, options: .init(semantic: .color))
        }
        
        let plane = MeshResource.generatePlane(width: 0.5, depth: 0.5)
        var material = SimpleMaterial()
        
        if let texture = texture {
            material.color = .init(tint: .white, texture: MaterialParameters.Texture(texture))
        }
        
        let entity = ModelEntity(mesh: plane, materials: [material])
        entity.position = [0, 0, -1]
        
        let anchor = AnchorEntity(world: [0, 0, -1])
        anchor.addChild(entity)
        arView.scene.addAnchor(anchor)
        
        // Firestoreに画像と位置を保存
        let position = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        PostManager.shared.uploadPost(image: image, position: position) { result in
            switch result {
            case .success:
                print("投稿が完了しました")
            case .failure(let error):
                print("投稿に失敗しました: \(error.localizedDescription)")
            }
        }
    }
    
    
    struct ARViewContainer: UIViewRepresentable {
        @Binding var arView: ARView
        
        func makeUIView(context: Context) -> ARView {
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal]
            arView.session.run(config)
            return arView
        }
        
        func updateUIView(_ uiView: ARView, context: Context) {}
    }
}

