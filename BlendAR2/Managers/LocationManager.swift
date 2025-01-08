import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var errorMessage: String?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkAuthorization()
    }

    // 権限の確認とリクエスト
    func checkAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()  // 使用中の権限をリクエスト
        case .restricted, .denied:
            errorMessage = "位置情報が許可されていません。"
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()  // 権限が許可されている場合、位置情報を取得
        @unknown default:
            errorMessage = "予期しないエラーが発生しました。"
        }
    }

    // 権限が変更されたときに呼び出される
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorization()
    }

    // 位置情報が更新されたときに呼び出される
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }

    // 位置情報の取得に失敗した場合
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "位置情報の取得に失敗しました: \(error.localizedDescription)"
    }
}
