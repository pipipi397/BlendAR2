import Foundation
import CoreLocation
import FirebaseFirestore

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }
    
    // 現在地に近い投稿を取得
    func filterNearbyPosts(completion: @escaping ([Post]) -> Void) {
        let radius: Double = 500  // 500m以内
        let currentLocation = userLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        Firestore.firestore().collection("posts").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            let posts = documents.map { Post(from: $0.data()) }.filter { post in
                let postLocation = CLLocation(latitude: post.position.latitude, longitude: post.position.longitude)
                let userLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                return userLocation.distance(from: postLocation) < radius
            }
            completion(posts)
        }
    }
}
