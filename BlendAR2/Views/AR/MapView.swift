import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @StateObject private var locationManager = LocationManager()

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true  // 現在地の表示を有効化
        mapView.userTrackingMode = .follow  // 現在地を自動で追尾
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let location = locationManager.userLocation {
            let region = MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            uiView.setRegion(region, animated: true)
        }
    }
}
