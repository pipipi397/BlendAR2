import SwiftUI
import RealityKit
import ARKit
import UIKit

/// SwiftUI で `ARPostViewContainerController` を利用するためのラッパー
struct ARPostViewContainer: UIViewControllerRepresentable {
    var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> ARPostViewContainerController {
        let controller = ARPostViewContainerController()
        controller.selectedImage = selectedImage
        return controller
    }

    func updateUIViewController(_ uiViewController: ARPostViewContainerController, context: Context) {
        // 必要に応じて UI を更新
    }
}
