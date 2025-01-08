import SwiftUI
import ARKit
import RealityKit

struct ARPostView: UIViewRepresentable {
    let image: UIImage
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        context.coordinator.arView = arView
        context.coordinator.setupAR()
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> ARCoordinator {
        return ARCoordinator(image: image)
    }
}
