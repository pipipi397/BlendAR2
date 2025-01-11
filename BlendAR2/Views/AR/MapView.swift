import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel
    @Binding var currentLocation: CLLocationCoordinate2D

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

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
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MKPointAnnotation else {
                print("選択されたピンが無効です")
                return
            }

            if let post = parent.viewModel.posts.first(where: {
                $0.position.latitude == annotation.coordinate.latitude &&
                $0.position.longitude == annotation.coordinate.longitude
            }) {
                print("選択された投稿: \(post)")

                let arView = UIHostingController(rootView: ARPostDisplayControllerWrapper(post: post))
                UIApplication.shared.windows.first?.rootViewController?.present(arView, animated: true)
            } else {
                print("該当する投稿データが見つかりません")
            }
        }

    }
}
