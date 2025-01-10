import SwiftUI
import RealityKit
import ARKit

struct ARDrawingView: UIViewControllerRepresentable {
    @Binding var screenshot: UIImage?

    func makeUIViewController(context: Context) -> ARDrawingViewController {
        let controller = ARDrawingViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: ARDrawingViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ARDrawingViewControllerDelegate {
        var parent: ARDrawingView

        init(_ parent: ARDrawingView) {
            self.parent = parent
        }

        func didFinishDrawing(_ screenshot: UIImage) {
            parent.screenshot = screenshot
        }
    }
}

class ARDrawingViewController: UIViewController, ARSessionDelegate {
    var arView: ARView!
    var delegate: ARDrawingViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)

        // ARセッション設定
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
        
        // 手書き完了ボタン
        let finishButton = UIButton(frame: CGRect(x: 20, y: 50, width: 100, height: 40))
        finishButton.setTitle("完了", for: .normal)
        finishButton.backgroundColor = .blue
        finishButton.addTarget(self, action: #selector(finishDrawing), for: .touchUpInside)
        view.addSubview(finishButton)
    }

    @objc private func finishDrawing() {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let screenshot = renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
        delegate?.didFinishDrawing(screenshot)
        dismiss(animated: true, completion: nil)
    }
}

protocol ARDrawingViewControllerDelegate {
    func didFinishDrawing(_ screenshot: UIImage)
}
