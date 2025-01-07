import SwiftUI
import ARKit
import RealityKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore

struct ARPostView: View {
    @Binding var selectedImage: UIImage?
    @State private var arView = ARView(frame: .zero)

    var body: some View {
        ZStack {
            ARViewContainer(arView: $arView)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                Button(action: {
                    placeImageInAR()
                }) {
                    Text("画像を配置")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            setupARSession()
        }
    }

    func placeImageInAR() {
        guard let selectedImage = selectedImage, let cgImage = selectedImage.cgImage else { return }

        let texture = try? TextureResource(image: cgImage, withName: "ImageTexture", options: .init(semantic: .color))

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

        // Firestoreに画像と位置情報を保存
        PostManager.shared.uploadImage(selectedImage) { result in
            switch result {
            case .success(let imageURL):
                // AR位置情報をCLLocationCoordinate2Dに変換してFirestoreに保存
                let arPosition = arView.cameraTransform.translation
                let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(arPosition.x), longitude: CLLocationDegrees(arPosition.y))
                
                PostManager.shared.savePost(imageURL: imageURL, location: location) { result in
                    if case .failure(let error) = result {
                        print("投稿の保存に失敗: \(error)")
                    }
                }
            case .failure(let error):
                print("画像アップロードに失敗: \(error)")
            }
        }
    }

    func setupARSession() {
        let arConfiguration = ARWorldTrackingConfiguration()
        arConfiguration.planeDetection = [.horizontal]
        arView.session.run(arConfiguration)
    }
}
