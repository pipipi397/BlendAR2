import Foundation
import FirebaseFirestore
import MapKit

class MapViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var annotations: [MKPointAnnotation] = []
    let db = Firestore.firestore()
    var following: [String] = [] // フォロー中のユーザーIDリスト

    func fetchPosts(currentLocation: CLLocationCoordinate2D) {
        guard !following.isEmpty else {
            print("フォロー中のユーザーがいません")
            self.posts = []
            self.annotations = []
            return
        }

        db.collection("posts")
            .whereField("userID", in: following) // フォロー中のユーザーのみ
            .whereField("position.latitude", isGreaterThan: currentLocation.latitude - 0.005)
            .whereField("position.latitude", isLessThan: currentLocation.latitude + 0.005)
            .whereField("position.longitude", isGreaterThan: currentLocation.longitude - 0.005)
            .whereField("position.longitude", isLessThan: currentLocation.longitude + 0.005)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("投稿取得エラー: \(error.localizedDescription)")
                    return
                }

                self.posts = snapshot?.documents.compactMap { document in
                    try? document.data(as: Post.self)
                } ?? []

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
