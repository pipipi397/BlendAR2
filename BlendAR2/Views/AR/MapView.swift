import SwiftUI
import MapKit
import FirebaseFirestore

struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(viewModel.annotations)

        print("マップに追加されたピン数: \(viewModel.annotations.count)")
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? MKPointAnnotation {
                print("ピンがタップされました: \(annotation.title ?? "タイトルなし")")
                presentARDisplay(annotation: annotation)
            }
        }

        private func presentARDisplay(annotation: MKPointAnnotation) {
            guard let latitude = annotation.coordinate.latitude as CLLocationDegrees?,
                  let longitude = annotation.coordinate.longitude as CLLocationDegrees? else { return }

            let postData: [String: Any] = [
                "latitude": latitude,
                "longitude": longitude,
                "altitude": 0.0 // 必要ならFirestoreから高度データを取得
            ]

            let arController = ARPostDisplayController()
            arController.postData = postData

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(arController, animated: true)
            }
        }
    }
}
