import Foundation
import Combine
import FirebaseFirestore
import CoreLocation
import MapKit

class MapViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var annotations: [MKPointAnnotation] = [] // ピン情報を管理

    func fetchPosts(currentLocation: CLLocationCoordinate2D) {
        let db = Firestore.firestore()
        db.collection("posts").getDocuments { snapshot, error in
            if let error = error {
                print("投稿の取得に失敗しました: \(error.localizedDescription)")
                return
            }

            self.posts = snapshot?.documents.compactMap { document in
                try? document.data(as: Post.self)
            } ?? []

            // 投稿データからピン情報を作成
            self.annotations = self.posts.map { post in
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: post.position.latitude, longitude: post.position.longitude)
                annotation.title = post.comment
                annotation.subtitle = post.imageURL
                return annotation
            }
        }
    }
}
