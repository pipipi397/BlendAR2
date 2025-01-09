import SwiftUI
import UIKit
import RealityKit
import ARKit
import CoreLocation

struct ARPostViewContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ARPostViewContainerController {
        return ARPostViewContainerController()
    }

    func updateUIViewController(_ uiViewController: ARPostViewContainerController, context: Context) {}
}

class ARPostViewContainerController: UIViewController {
    var arView: ARView!
    var selectedImage: UIImage?
    var anchorEntity: AnchorEntity?
    var placedEntity: ModelEntity?
    private var locationManager = LocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupARView()
        startARSession()
        addGestureRecognizers()
        setupPostButton()
    }

    private func setupARView() {
        arView = ARView(frame: view.bounds)
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
        let results = arView.raycast(from: tapLocation, allowing: .existingPlaneGeometry, alignment: .horizontal)

        guard let firstResult = results.first else {
            print("平面が見つかりませんでした")
            return
        }

        let anchor = AnchorEntity(world: firstResult.worldTransform)
        arView.scene.addAnchor(anchor)

        if let image = selectedImage, let cgImage = image.cgImage {
            let plane = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3))
            let texture = try? TextureResource(image: cgImage, options: .init(semantic: .color))
            var material = SimpleMaterial(color: .white, isMetallic: false)
            material.baseColor = .texture(texture!)
            plane.model?.materials = [material]
            anchor.addChild(plane)
        }

        print("タップ位置にオブジェクトを配置しました")
    }

    private func setupPostButton() {
        let postButton = UIButton(type: .system)
        postButton.setTitle("投稿する", for: .normal)
        postButton.backgroundColor = .systemBlue
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

        guard let location = locationManager.userLocation else {
            print("位置情報が取得できません")
            return
        }

        PostManager.shared.uploadPost(image: image, location: location) { [weak self] result in
            switch result {
            case .success:
                print("投稿が成功しました")
                self?.dismiss(animated: true)
            case .failure(let error):
                print("投稿に失敗しました: \(error.localizedDescription)")
                self?.showAlert(title: "エラー", message: error.localizedDescription)
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
