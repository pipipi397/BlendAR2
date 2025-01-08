import SwiftUI
import RealityKit
import ARKit
import simd
import CoreLocation

struct ARPostViewContainer: UIViewControllerRepresentable {
    var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> ARPostViewContainerController {
        let controller = ARPostViewContainerController()
        controller.selectedImage = selectedImage
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ARPostViewContainerController, context: Context) {}
}

class ARPostViewContainerController: UIViewController {
    var arView: ARView!
    var selectedImage: UIImage?
    var anchorEntity: AnchorEntity?
    var placedEntity: ModelEntity?
    var wallNormal: SIMD3<Float> = [0, 1, 0]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupARView()
        startARSession()
        addGestureRecognizers()
        setupPostButton()
    }

    private func setupARView() {
        arView = ARView(frame: .zero)
        arView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arView)
        
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func startARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        arView.session.run(configuration)
    }

    private func addGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        let results = arView.raycast(from: tapLocation, allowing: .existingPlaneGeometry, alignment: .any)

        guard let firstResult = results.first else {
            print("平面が見つかりませんでした")
            return
        }

        let transform = Transform(matrix: firstResult.worldTransform)
        if let entity = placedEntity {
            moveObject(entity: entity, to: transform)
        } else {
            placeObjectInAR(image: selectedImage, transform: transform)
        }
    }

    private func moveObject(entity: ModelEntity, to transform: Transform) {
        if let existingAnchor = anchorEntity {
            arView.scene.removeAnchor(existingAnchor)
        }

        let newAnchor = AnchorEntity(world: transform.matrix)
        newAnchor.addChild(entity)
        arView.scene.addAnchor(newAnchor)
        anchorEntity = newAnchor
    }

    private func placeObjectInAR(image: UIImage?, transform: Transform) {
        guard let image = image, let cgImage = image.cgImage else {
            print("画像をCGImageに変換できませんでした")
            return
        }

        let plane = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3))
        let material = SimpleMaterial(color: .white, isMetallic: false)

        guard let texture = try? TextureResource.generate(from: cgImage, options: .init(semantic: .color)) else {
            print("テクスチャ生成に失敗しました")
            return
        }

        var materialWithTexture = material
        materialWithTexture.baseColor = MaterialColorParameter.texture(texture)
        plane.model?.materials = [materialWithTexture]

        let anchor = AnchorEntity(world: transform.matrix)
        anchor.addChild(plane)
        arView.scene.addAnchor(anchor)

        placedEntity = plane
        anchorEntity = anchor
    }

    private func setupPostButton() {
        let postButton = UIButton(type: .system)
        postButton.setTitle("投稿する", for: .normal)
        postButton.backgroundColor = UIColor.systemBlue
        postButton.setTitleColor(.white, for: .normal)
        postButton.layer.cornerRadius = 10
        postButton.addTarget(self, action: #selector(handlePostButton), for: .touchUpInside)

        postButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(postButton)
        
        NSLayoutConstraint.activate([
            postButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            postButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            postButton.widthAnchor.constraint(equalToConstant: 200),
            postButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func handlePostButton() {
        guard let image = selectedImage else {
            print("画像が選択されていません")
            return
        }

        PostManager.shared.uploadPost(image: image) { [weak self] result in
            switch result {
            case .success:
                print("投稿が完了しました")
                self?.navigateToMainView()  // 投稿成功後にMainViewへ遷移
            case .failure(let error):
                print("投稿エラー: \(error.localizedDescription)")
                self?.showAlert(title: "エラー", message: error.localizedDescription)
            }
        }
    }

    private func navigateToMainView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: MainView())
            window.makeKeyAndVisible()
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
