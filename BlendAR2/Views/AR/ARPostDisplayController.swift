import UIKit
import RealityKit
import ARKit

class ARPostDisplayController: UIViewController {
    var arView: ARView!
    var postData: [String: Any]?

    override func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)

        setupARSession()

        if let postData = postData,
           let imageURL = postData["imageURL"] as? String {
            placeObject(with: imageURL)
        }
    }

    private func setupARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    private func placeObject(with imageURL: String) {
        downloadImage(from: URL(string: imageURL)!) { [weak self] image in
            guard let self = self, let image = image, let cgImage = image.cgImage else { return }

            let aspectRatio = Float(image.size.width / image.size.height)
            let plane = ModelEntity(mesh: .generatePlane(width: 0.3, height: 0.3 / aspectRatio))

            if let texture = try? TextureResource(image: cgImage, options: .init(semantic: .color)) {
                var material = SimpleMaterial()
                material.baseColor = .texture(texture)
                plane.model?.materials = [material]
            }

            let anchor = AnchorEntity(world: SIMD3<Float>(0, 0, -0.5))
            anchor.addChild(plane)
            self.arView.scene.addAnchor(anchor)
        }
    }

    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    completion(image)
                }
            } catch {
                DispatchQueue.main.async {
                    print("画像ダウンロードエラー: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
}
