import SwiftUI
import RealityKit
import ARKit

struct ARDrawingControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ARDrawingViewController {
        return ARDrawingViewController()
    }

    func updateUIViewController(_ uiViewController: ARDrawingViewController, context: Context) {}

    class ARDrawingViewController: UIViewController {
        var arView: ARView!

        override func viewDidLoad() {
            super.viewDidLoad()

            arView = ARView(frame: view.bounds)
            view.addSubview(arView)

            setupARSession()
            setupDrawing()
        }

        private func setupARSession() {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal]
            arView.session.run(configuration)
        }

        private func setupDrawing() {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            arView.addGestureRecognizer(panGesture)
        }

        @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
            let location = sender.location(in: arView)
            switch sender.state {
            case .began, .changed:
                if let hitTestResult = arView.hitTest(location).first {
                    let sphere = ModelEntity(mesh: .generateSphere(radius: 0.01))
                    sphere.position = hitTestResult.position // 修正箇所
                    let anchor = AnchorEntity()
                    anchor.addChild(sphere)
                    arView.scene.addAnchor(anchor)
                }
            default:
                break
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            arView.session.pause()
        }
    }
}
