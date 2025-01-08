import SwiftUI
import RealityKit
import FirebaseFirestore
import simd
import CoreLocation

struct ARPostViewContainer: UIViewControllerRepresentable {
    var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> ARPostViewContainerController {
        let controller = ARPostViewContainerController()
        controller.selectedImage = selectedImage
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ARPostViewContainerController, context: Context) {
        // 必要に応じて更新処理
    }
}

class ARPostViewContainerController: UIViewController {
    var arView = ARView(frame: .zero)
    var selectedImage: UIImage?
    var anchor = AnchorEntity()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupARView()
        if let image = selectedImage {
            placeObjectInAR(image: image)
        }
        setupPostButton()
    }

    private func setupARView() {
        arView.automaticallyConfigureSession = true
        view.addSubview(arView)
    }

    private func placeObjectInAR(image: UIImage) {
        let boxMesh = MeshResource.generateBox(size: [0.5, 0.01, 0.5])
        let plane = ModelEntity(mesh: boxMesh)
        
        if let texture = try? TextureResource.generate(from: image.cgImage!, options: .init(semantic: .color)) {
            var material = SimpleMaterial()
            material.baseColor = MaterialColorParameter.texture(texture)
            plane.model?.materials = [material]
        }
        anchor.addChild(plane)
        arView.scene.addAnchor(anchor)
    }

    private func setupPostButton() {
        let button = UIButton(frame: CGRect(x: 20, y: view.bounds.height - 100, width: view.bounds.width - 40, height: 50))
        button.setTitle("投稿する", for: .normal)
        button.backgroundColor = .green
        button.addTarget(self, action: #selector(postObject), for: .touchUpInside)
        view.addSubview(button)
    }

    @objc private func postObject() {
        guard let image = selectedImage else { return }
        
        PostManager.shared.uploadImage(image) { result in
            switch result {
            case .success(let imageURL):
                let position = CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125) // 仮の位置情報
                PostManager.shared.savePost(imageURL: imageURL, location: position) { saveResult in
                    switch saveResult {
                    case .success:
                        print("投稿が完了しました")
                        self.dismiss(animated: true)
                    case .failure(let error):
                        print("投稿に失敗しました: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("画像のアップロードに失敗しました: \(error.localizedDescription)")
            }
        }
    }
}
