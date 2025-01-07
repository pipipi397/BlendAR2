import UIKit
import ARKit
import RealityKit

class ARCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var arView: ARView?
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage,
              let arView = arView else { return }
        
        let plane = MeshResource.generatePlane(width: 0.5, depth: 0.5)
        var texture: TextureResource?
        
        if let cgImage = image.cgImage {
            if #available(iOS 18.0, *) {
                texture = try? TextureResource(image: cgImage, options: .init(semantic: .color))
            } else {
                texture = try? TextureResource.generate(from: cgImage, options: .init(semantic: .color))
            }
        }
        
        let material = SimpleMaterial(textureResource: texture)
        let entity = ModelEntity(mesh: plane, materials: [material])
        entity.scale = SIMD3<Float>(0.5, 0.5, 0.5)
        
        let anchor = AnchorEntity(plane: .horizontal)
        anchor.addChild(entity)
        arView.scene.addAnchor(anchor)
        
        picker.dismiss(animated: true, completion: nil)
    }
}
