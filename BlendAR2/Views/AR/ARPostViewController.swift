import SwiftUI
import RealityKit
import FirebaseFirestore
import simd

class ARPostViewController: UIViewController {
    var arView = ARView(frame: .zero)
    var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupARView()
        fetchPosts()
    }

    private func setupARView() {
        arView.automaticallyConfigureSession = true
        view.addSubview(arView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        arView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        arView.addGestureRecognizer(pinchGesture)
    }

    private func fetchPosts() {
        Firestore.firestore().collection("posts")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.posts = documents.map { Post(from: $0.data()) }
                self.placeImagesInAR()
            }
    }

    private func placeImagesInAR() {
        for post in posts {
            let transform = convertToMatrix(latitude: post.position.latitude, longitude: post.position.longitude)
            let anchor = AnchorEntity(world: transform)
            
            guard let url = URL(string: post.imageURL) else { continue }
            let texture = try? TextureResource.load(contentsOf: url)
            
            var material = SimpleMaterial()
            material.baseColor = MaterialColorParameter.texture(texture!)
            
            let plane = ModelEntity(mesh: .generatePlane(width: 1.0, height: 1.0), materials: [material])
            
            arView.scene.addAnchor(anchor)
            anchor.addChild(plane)
        }
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        if let entity = arView.entity(at: tapLocation) {
            entity.removeFromParent()
        }
    }

    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: arView)
        if let entity = arView.entity(at: sender.location(in: arView)) {
            entity.transform.translation += SIMD3<Float>(
                Float(translation.x) / 500,
                0,
                -Float(translation.y) / 500
            )
            sender.setTranslation(.zero, in: arView)
        }
    }

    @objc private func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if let entity = arView.entity(at: sender.location(in: arView)) {
            let scale = Float(sender.scale)
            entity.transform.scale *= SIMD3<Float>(scale, scale, scale)
            sender.scale = 1.0
        }
    }

    private func convertToMatrix(latitude: Double, longitude: Double) -> float4x4 {
        var transform = matrix_identity_float4x4
        let scaleFactor: Float = 1000.0
        let x = Float(latitude) / scaleFactor
        let z = Float(longitude) / scaleFactor
        transform.columns.3 = SIMD4<Float>(x, 0, z, 1)
        return transform
    }
}
