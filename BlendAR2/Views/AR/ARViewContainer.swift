import SwiftUI
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    static let sharedARView = ARView(frame: .zero)

    func makeUIView(context: Context) -> ARView {
        return ARViewContainer.sharedARView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
