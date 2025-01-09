import UIKit
import RealityKit
import ARKit

class ARPostDisplayController: UIViewController {
    var arView: ARView!
    var imageURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        arView = ARView(frame: view.bounds)
        view.addSubview(arView)

        setupARSession()

        if let imageURL = imageURL {
            downloadImage(from: imageURL) { [weak self] image in
                guard let self = self else { return }
                if let image = image {
                    let resizedImage = self.resizeImage(image: image, targetSize: CGSize(width: 1024, height: 1024))
                    self.addImageToAR(resizedImage)
                }
            }
        }
    }

    private func setupARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .none
        arView.session.run(configuration)
        print("ARセッション設定成功")
    }

    private func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("無効なURL: \(urlString)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("画像のダウンロードに失敗: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data, !data.isEmpty, let image = UIImage(data: data) else {
                print("ダウンロードした画像データが無効または空です")
                completion(nil)
                return
            }

            print("画像のダウンロードに成功: サイズ=\(image.size)")
            completion(image)
        }.resume()
    }

    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        let newSize = widthRatio < heightRatio
            ? CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            : CGSize(width: size.width * heightRatio, height: size.height * heightRatio)

        let rect = CGRect(origin: .zero, size: newSize)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image
    }

    private func addImageToAR(_ image: UIImage) {
        DispatchQueue.main.async {
            guard let cgImage = image.cgImage else {
                print("画像のCGImage変換に失敗しました")
                return
            }

            let plane = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3))
            print("モデルエンティティ生成成功")

            var material = SimpleMaterial(color: .white, isMetallic: false)
            guard let texture = try? TextureResource(image: cgImage, options: .init(semantic: .color)) else {
                print("テクスチャ生成に失敗しました")
                return
            }
            material.baseColor = .texture(texture)
            plane.model?.materials = [material]
            print("マテリアル適用成功")

            let anchor = AnchorEntity(world: .zero)
            anchor.addChild(plane)
            self.arView.scene.addAnchor(anchor)
            print("モデルをAR空間に配置しました")
        }
    }
}
