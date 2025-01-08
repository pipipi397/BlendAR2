import SwiftUI
import RealityKit

struct ARViewContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ARViewController {
        let controller = ARViewController()
        return controller
    }

    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        // 必要に応じて更新処理
    }
}

class ARViewController: UIViewController {
    var arView = ARView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        arView.automaticallyConfigureSession = true
        view.addSubview(arView)
    }
}
