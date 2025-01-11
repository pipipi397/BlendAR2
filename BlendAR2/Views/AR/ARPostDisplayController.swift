import UIKit
import RealityKit

class ARPostDisplayController: UIViewController {
    var postData: [String: String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupARView()
    }

    private func setupARView() {
        guard let arView = self.view as? ARView else { return }
        guard let comment = postData?["comment"], let imageURL = postData?["imageURL"] else { return }

        print("ARデータ: コメント - \(comment), 画像URL - \(imageURL)")

        // 投稿画像をダウンロードしてAR空間に表示
        downloadImage(from: URL(string: imageURL)!) { [weak self] image in
            guard let self = self, let image = image, let cgImage = image.cgImage else { return }

            let aspectRatio = Float(image.size.width / image.size.height)
            let plane = ModelEntity(mesh: .generatePlane(width: 0.5, height: 0.5 / aspectRatio))

            if let texture = try? TextureResource(image: cgImage, options: .init(semantic: .color)) {
                var material = SimpleMaterial()
                material.baseColor = .texture(texture)
                plane.model?.materials = [material]
            }

            let anchor = AnchorEntity(world: [0, 0, -1]) // ユーザー前方1mに配置
            anchor.addChild(plane)
            arView.scene.addAnchor(anchor)
        }
    }

    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                completion(UIImage(data: data))
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
