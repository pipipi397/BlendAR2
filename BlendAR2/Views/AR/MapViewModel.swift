import FirebaseFirestore
import MapKit

class MapViewModel: ObservableObject {
    @Published var annotations: [MKPointAnnotation] = []

    func fetchPosts() {
        Firestore.firestore().collection("posts").getDocuments { snapshot, error in
            if let error = error {
                print("Firestoreエラー: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("Firestoreに投稿データがありません")
                return
            }

            print("Firestoreから取得したドキュメント数: \(documents.count)")

            let posts = documents.compactMap { doc -> MKPointAnnotation? in
                let data = doc.data()
                print("ドキュメントデータ: \(data)")

                guard let position = data["position"] as? [String: Double],
                      let latitude = position["latitude"],
                      let longitude = position["longitude"] else {
                          print("位置情報が無効: \(data)")
                          return nil
                      }

                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                annotation.title = data["imageURL"] as? String // 投稿画像の URL
                annotation.subtitle = data["userID"] as? String // 投稿ユーザーの ID
                return annotation
            }

            DispatchQueue.main.async {
                self.annotations = posts
                print("生成されたピン数: \(self.annotations.count)")
            }
        }
    }
}
