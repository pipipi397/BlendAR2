import UIKit
import RealityKit
import ARKit

class ARPostDisplayController: UIViewController {
    var arView: ARView!
    var postData: [String: Any]? // 投稿データを格納

    override func loadView() {
        arView = ARView(frame: .zero)
        view = arView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupARSession()

        // 投稿データを使用して画像を配置
        if let postData = postData,
           let imageURL = postData["imageURL"] as? String {
            placeObject(with: imageURL)
        }
    }

    private func setupARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)
    }

    private func placeObject(with imageURL: String) {
        guard let url = URL(string: imageURL) else {
            print("無効な画像URL: \(imageURL)")
            return
        }

        // 画像のダウンロードとAR空間への配置
        downloadImage(from: url) { [weak self] image in
            guard let self = self, let image = image, let cgImage = image.cgImage else { return }

            // アスペクト比を保持して平面を生成
            let aspectRatio = Float(image.size.width / image.size.height)
            let plane = ModelEntity(mesh: .generatePlane(width: 0.3, height: 0.3 / aspectRatio))

            // テクスチャを設定
            if let texture = try? TextureResource(image: cgImage, options: .init(semantic: .color)) {
                var material = SimpleMaterial()
                material.baseColor = .texture(texture) // テクスチャを直接設定
                plane.model?.materials = [material]
            } else {
                print("テクスチャの生成に失敗しました")
            }

            // アンカーを作成して配置
            let anchor = AnchorEntity(world: SIMD3<Float>(0, 0, -0.5))
            anchor.addChild(plane)
            self.arView.scene.addAnchor(anchor)
        }
    }

    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("画像ダウンロードエラー: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                print("画像データが無効です")
                completion(nil)
                return
            }

            completion(image)
        }.resume()
    }
}
