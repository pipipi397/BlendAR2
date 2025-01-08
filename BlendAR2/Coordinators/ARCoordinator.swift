import UIKit
import ARKit
import RealityKit

class ARCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var arView: ARView?
    var image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init()
    }
    
    func setupAR() {
        guard let arView = arView else { return }
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
        
        placeImageInAR(image)
    }
    
    func placeImageInAR(_ image: UIImage) {
        guard let arView = arView else { return }
        
        let plane = MeshResource.generatePlane(width: 0.5, depth: 0.5)
        var texture: TextureResource?

        if let cgImage = image.cgImage {
            if #available(iOS 18.0, *) {
                texture = try? TextureResource(image: cgImage, options: .init(semantic: .color))
            } else {
                texture = try? TextureResource.generate(from: cgImage, options: .init(semantic: .color))
            }
        }
        
        var material = SimpleMaterial()
        
        // テクスチャが取得できた場合
        if let texture = texture {
            material.baseColor = MaterialColorParameter.texture(texture)
        } else {
            // テクスチャがない場合はデフォルトで白
            material.baseColor = MaterialColorParameter.color(.white)
        }
        
        let entity = ModelEntity(mesh: plane, materials: [material])
        entity.scale = SIMD3<Float>(0.5, 0.5, 0.5)
        
        let anchor = AnchorEntity(plane: .horizontal)
        anchor.addChild(entity)
        arView.scene.addAnchor(anchor)
    }
}
