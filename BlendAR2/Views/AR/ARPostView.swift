import SwiftUI
import RealityKit
import FirebaseFirestore
import simd

struct ARPostView: View {
    @State private var arView = ARView(frame: .zero)
    @State private var posts: [Post] = []

    var body: some View {
        ZStack {
            ARViewContainer(arView: $arView)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
        .onAppear {
            fetchPosts()
        }
    }

    // Firestoreから投稿データを取得
    private func fetchPosts() {
        Firestore.firestore().collection("posts").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            self.posts = documents.map { Post(from: $0.data()) }
            placeImagesInAR()
        }
    }

    // AR空間にオブジェクトを配置
    private func placeImagesInAR() {
        for post in posts {
            let transform = convertToMatrix(latitude: post.position.latitude, longitude: post.position.longitude)
            let anchor = AnchorEntity(world: transform)
            
            let material = SimpleMaterial(color: .white, isMetallic: false)
            let plane = ModelEntity(mesh: .generatePlane(width: 0.5, depth: 0.5), materials: [material])
            
            arView.scene.addAnchor(anchor)
            anchor.addChild(plane)
        }
    }
    
    // 緯度経度をAR空間のfloat4x4座標に変換する関数
    private func convertToMatrix(latitude: Double, longitude: Double) -> float4x4 {
        // デフォルトの単位行列
        var transform = matrix_identity_float4x4
        
        // 緯度経度をAR空間のスケールに変換
        let scaleFactor: Float = 1000.0  // 座標のスケール調整
        let x = Float(latitude) / scaleFactor
        let z = Float(longitude) / scaleFactor
        
        // 行列に変換 (Y軸はそのまま0で配置)
        transform.columns.3 = SIMD4<Float>(x, 0, z, 1)
        return transform
    }
}
