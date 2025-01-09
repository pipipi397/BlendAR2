import SwiftUI
import MapKit

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
        print("更新前のピン数: \(uiView.annotations.count)")

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
            if let annotation = view.annotation as? MKPointAnnotation,
               let imageURL = annotation.title {
                print("ピンがタップされました: \(imageURL)")
                // AR 表示に遷移
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    let arPostView = ARPostDisplayController()
                    arPostView.imageURL = imageURL
                    rootViewController.present(arPostView, animated: true, completion: nil)
                }
            }
        }

    }
}
