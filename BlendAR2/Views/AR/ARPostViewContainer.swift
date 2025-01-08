import SwiftUI
import RealityKit
import FirebaseFirestore
import simd

struct ARPostViewContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ARPostViewController {
        return ARPostViewController()
    }
    
    func updateUIViewController(_ uiViewController: ARPostViewController, context: Context) {
        // 必要に応じて更新処理
    }
}
