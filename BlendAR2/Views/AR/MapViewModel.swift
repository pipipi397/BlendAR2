import FirebaseFirestore
import MapKit
import CoreLocation

class MapViewModel: ObservableObject {
    @Published var annotations: [MKPointAnnotation] = []

    func fetchPosts(currentLocation: CLLocationCoordinate2D?) {
        guard let currentLocation = currentLocation else {
            print("現在地が取得できません")
            return
        }

        Firestore.firestore().collection("posts").getDocuments { snapshot, error in
            if let error = error {
                print("Firestoreエラー: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("Firestoreからの投稿データが空です")
                return
            }

            let maxDistance: Double = 500.0 // 500m以内の投稿のみ表示

            DispatchQueue.main.async {
                self.annotations = documents.compactMap { doc in
                    let data = doc.data()
                    guard let position = data["position"] as? [String: Double],
                          let latitude = position["latitude"],
                          let longitude = position["longitude"] else { return nil }

                    let postLocation = CLLocation(latitude: latitude, longitude: longitude)
                    let userLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)

                    if userLocation.distance(from: postLocation) <= maxDistance {
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        annotation.title = data["comment"] as? String // コメントをタイトルに表示
                        annotation.subtitle = data["imageURL"] as? String // 画像URLをサブタイトルに格納
                        return annotation
                    }

                    return nil
                }

                print("マップ上のピン数: \(self.annotations.count)") // デバッグログ
            }
        }
    }
}
