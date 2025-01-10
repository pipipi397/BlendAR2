import FirebaseFirestore
import MapKit

class MapViewModel: ObservableObject {
    @Published var annotations: [MKPointAnnotation] = []

    func fetchPosts(currentLocation: CLLocationCoordinate2D, userID: String) {
        Firestore.firestore().collection("posts")
            .whereField("userID", isEqualTo: userID) // ユーザーの投稿に限定
            .whereField("position.latitude", isGreaterThan: currentLocation.latitude - 0.05)
            .whereField("position.latitude", isLessThan: currentLocation.latitude + 0.05)
            .whereField("position.longitude", isGreaterThan: currentLocation.longitude - 0.05)
            .whereField("position.longitude", isLessThan: currentLocation.longitude + 0.05)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Firestoreエラー: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("Firestoreからの投稿データが空です")
                    return
                }

                DispatchQueue.main.async {
                    self.annotations = documents.compactMap { doc in
                        let data = doc.data()
                        guard let position = data["position"] as? [String: Double],
                              let latitude = position["latitude"],
                              let longitude = position["longitude"] else {
                            print("位置情報が不正です: \(data)")
                            return nil
                        }

                        let annotation = MKPointAnnotation()
                        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        annotation.title = data["comment"] as? String ?? "タイトルなし"
                        annotation.subtitle = data["imageURL"] as? String ?? "URLなし"
                        return annotation
                    }

                    print("現在のピン数: \(self.annotations.count)")
                }
            }
    }
}
