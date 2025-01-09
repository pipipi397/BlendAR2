import UIKit
import RealityKit
import ARKit

class ARPostDisplayController: UIViewController {
    var arView: ARView!
    var postData: [String: Any]? // 投稿データを格納

    override func viewDidLoad() {
        super.viewDidLoad()

        arView = ARView(frame: view.bounds)
        view.addSubview(arView)

        setupARSession()

        // 投稿データを基にオブジェクトを配置
        if let postData = postData,
           let arAnchorPositionData = postData["arAnchorPosition"] as? [String: [Double]],
           let arAnchorPosition = parseMatrix(from: arAnchorPositionData),
           let imageURL = postData["imageURL"] as? String {
            placeObject(at: arAnchorPosition, with: imageURL)
        }
    }

    private func setupARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .none
        configuration.isAutoFocusEnabled = false // 自動フォーカスを無効化
        arView.session.run(configuration)
    }



    private func parseMatrix(from data: [String: [Double]]) -> simd_float4x4? {
        guard let column0 = data["column0"],
              let column1 = data["column1"],
              let column2 = data["column2"],
              let column3 = data["column3"],
              column0.count == 4, column1.count == 4, column2.count == 4, column3.count == 4 else {
            print("ARアンカー座標データが無効です")
            return nil
        }

        return simd_float4x4(
            SIMD4<Float>(Float(column0[0]), Float(column0[1]), Float(column0[2]), Float(column0[3])),
            SIMD4<Float>(Float(column1[0]), Float(column1[1]), Float(column1[2]), Float(column1[3])),
            SIMD4<Float>(Float(column2[0]), Float(column2[1]), Float(column2[2]), Float(column2[3])),
            SIMD4<Float>(Float(column3[0]), Float(column3[1]), Float(column3[2]), Float(column3[3]))
        )
    }

    private func placeObject(at arAnchorPosition: simd_float4x4, with imageURL: String) {
        let anchor = AnchorEntity(world: arAnchorPosition)

        let plane = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3))

        // テクスチャを画像URLで設定
        downloadImage(from: imageURL) { [weak self] image in
            guard let self = self, let image = image, let cgImage = image.cgImage else { return }

            let texture = try? TextureResource(image: cgImage, options: .init(semantic: .color))
            var material = SimpleMaterial(color: .white, isMetallic: false)
            material.baseColor = .texture(texture!)
            plane.model?.materials = [material]

            anchor.addChild(plane)
            self.arView.scene.addAnchor(anchor)
            print("画像付きオブジェクトをAR空間に配置しました")
        }
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

            guard let data = data, let image = UIImage(data: data) else {
                print("画像データが無効または空です")
                completion(nil)
                return
            }

            print("画像のダウンロードに成功")
            completion(image)
        }.resume()
    }
}
