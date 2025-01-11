import UIKit
import RealityKit

class ARPostDisplayController: UIViewController {
    var postData: [String: String]? // 投稿データを保持するプロパティ

    override func viewDidLoad() {
        super.viewDidLoad()
        setupARView()
    }

    private func setupARView() {
        let arView = ARView(frame: self.view.bounds)
        self.view.addSubview(arView)

        guard let postData = postData else {
            print("投稿データがありません")
            return
        }

        guard let imageURLString = postData["imageURL"],
              let imageURL = URL(string: imageURLString) else {
            print("画像URLが無効です")
            return
        }

        downloadImage(from: imageURL) { [weak self] image in
            guard let self = self, let image = image, let cgImage = image.cgImage else { return }

            let aspectRatio = Float(image.size.width / image.size.height)
            let plane = ModelEntity(mesh: .generatePlane(width: 0.5, height: 0.5 / aspectRatio))

            if let texture = try? TextureResource(image: cgImage, options: .init(semantic: .color)) {
                var material = SimpleMaterial()
                material.baseColor = .texture(texture)
                plane.model?.materials = [material]
            }

            let anchor = AnchorEntity(world: [0, 0, -1])
            anchor.addChild(plane)
            arView.scene.addAnchor(anchor)
        }
    }

    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("画像ダウンロードエラー: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let data = data {
                completion(UIImage(data: data))
            } else {
                completion(nil)
            }
        }.resume()
    }
}
