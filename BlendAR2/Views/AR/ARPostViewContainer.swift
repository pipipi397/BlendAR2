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
    var anchorEntity: AnchorEntity?  // アンカーを保持
    var placedEntity: ModelEntity?  // 配置されたオブジェクト
    var wallNormal: SIMD3<Float> = [0, 1, 0]  // 初期はy軸回転

    override func viewDidLoad() {
        super.viewDidLoad()
        setupARView()
        startARSession()
        addGestureRecognizers()
    }

    // ARViewのセットアップ
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

    // ARセッションの開始 (水平と垂直面の検出を有効化)
    private func startARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]  // 垂直面も検出
        arView.session.run(configuration)
    }

    // ジェスチャー追加 (タップ, ピンチ, パン, 回転)
    private func addGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(tapGesture)
    }

    // タップで画像を配置または再配置
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        let results = arView.raycast(from: tapLocation, allowing: .existingPlaneGeometry, alignment: .any)
        
        guard let firstResult = results.first else {
            print("平面が見つかりませんでした")
            return
        }

        let transform = Transform(matrix: firstResult.worldTransform)
        
        // 壁の法線ベクトルを取得
        wallNormal = normalize(SIMD3<Float>(firstResult.worldTransform.columns.2.x,
                                            firstResult.worldTransform.columns.2.y,
                                            firstResult.worldTransform.columns.2.z))

        if let entity = placedEntity {
            moveObject(entity: entity, to: transform)
        } else {
            placeObjectInAR(image: selectedImage, transform: transform)
        }
    }

    // オブジェクトを移動
    private func moveObject(entity: ModelEntity, to transform: Transform) {
        if let existingAnchor = anchorEntity {
            arView.scene.removeAnchor(existingAnchor)
        }

        let newAnchor = AnchorEntity(world: transform.matrix)
        newAnchor.addChild(entity)
        arView.scene.addAnchor(newAnchor)
        anchorEntity = newAnchor
    }

    // AR空間にオブジェクトを配置
    private func placeObjectInAR(image: UIImage?, transform: Transform) {
        guard let image = image, let cgImage = image.cgImage else {
            print("画像をCGImageに変換できませんでした")
            return
        }

        let boxMesh = MeshResource.generateBox(size: [0.3, 0.01, 0.3])
        let plane = ModelEntity(mesh: boxMesh)
        
        guard let texture = try? TextureResource.init(image: cgImage, withName: "customTexture", options: .init(semantic: .color)) else {
            print("テクスチャ生成に失敗しました")
            return
        }

        var material = SimpleMaterial()
        material.color = SimpleMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
        plane.model?.materials = [material]

        // 壁にぴったりと配置
        var adjustedTransform = transform  // ここをvarに変更
        adjustedTransform.translation += wallNormal * 0.015  // 少し押し付けて配置

        let anchor = AnchorEntity(world: adjustedTransform.matrix)
        anchor.addChild(plane)
        arView.scene.addAnchor(anchor)

        placedEntity = plane
        anchorEntity = anchor
    }

    // ピンチでスケール変更
    @objc private func handlePinch(_ sender: UIPinchGestureRecognizer) {
        guard let entity = placedEntity else { return }
        let scale = Float(sender.scale)
        entity.scale *= SIMD3<Float>(scale, scale, scale)
        sender.scale = 1.0
    }

    // 1本指のパンでオブジェクトを移動
    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let entity = placedEntity else { return }
        
        let translation = sender.translation(in: arView)
        
        let results = arView.raycast(from: sender.location(in: arView), allowing: .existingPlaneInfinite, alignment: .any)
        
        guard let firstResult = results.first else { return }
        
        let newTransform = Transform(matrix: firstResult.worldTransform)
        
        entity.transform.translation = newTransform.translation
        
        sender.setTranslation(.zero, in: arView)  // リセット
    }

    // 2本指で壁に沿って回転 (y軸回転のみ)
    @objc private func handleTwoFingerPan(_ sender: UIPanGestureRecognizer) {
        guard let entity = placedEntity else { return }
        let translation = sender.translation(in: arView)

        let rotationY = -Float(translation.x) * 0.02  // 左右移動でy軸回転のみ

        let yAxisRotation = simd_quatf(angle: rotationY, axis: wallNormal)  // 壁の法線方向に回転
        
        entity.transform.rotation *= yAxisRotation
        sender.setTranslation(.zero, in: arView)
    }
}
