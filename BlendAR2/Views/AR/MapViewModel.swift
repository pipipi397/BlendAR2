import Foundation
import FirebaseFirestore
import MapKit

class MapViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var annotations: [MKPointAnnotation] = []
    let db = Firestore.firestore()
    var following: [String] = [] // フォロー中のユーザーIDリスト
    
    func fetchPosts(currentLocation: CLLocationCoordinate2D) {
        print("現在地: \(currentLocation.latitude), \(currentLocation.longitude)")
        
        db.collection("posts")
            .whereField("position", isGreaterThan: GeoPoint(latitude: currentLocation.latitude - 0.005, longitude: currentLocation.longitude - 0.005))
            .whereField("position", isLessThan: GeoPoint(latitude: currentLocation.latitude + 0.005, longitude: currentLocation.longitude + 0.005))
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Firestoreクエリエラー: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("取得された投稿データなし")
                    return
                }
                
                print("取得した投稿数: \(documents.count)")
                documents.forEach { document in
                    print("投稿データ: \(document.data())")
                }
                
                // 投稿データを配列に変換
                self.posts = documents.compactMap { document in
                    let data = document.data()
                    guard let position = data["position"] as? GeoPoint else { return nil }
                    return Post(
                        id: document.documentID,
                        imageURL: data["imageURL"] as? String ?? "",
                        position: position,
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                        comment: data["comment"] as? String ?? "",
                        userID: data["userID"] as? String ?? "",
                        displayName: data["displayName"] as? String ?? "Unknown User"
                    )
                }
                
                print("解析後の投稿データ: \(self.posts)")
                
                // ピンを生成
                self.annotations = self.posts.map { post in
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: post.position.latitude, longitude: post.position.longitude)
                    annotation.title = post.comment
                    return annotation
                }
                print("生成されたピン数: \(self.annotations.count)")
            }
    }
}
