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
               let imageURL = annotation.title,
               let arAnchorPosition = annotation.subtitle { // 必要なら subtitle に他のデータを格納
                print("ピンがタップされました: \(imageURL)")

                // ARPostDisplayController に投稿データを渡す
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    let arPostViewController = ARPostDisplayController()
                    arPostViewController.postData = [
                        "imageURL": imageURL,
                        "arAnchorPosition": arAnchorPosition // 必要に応じて適切にデータを変換
                    ]
                    rootViewController.present(arPostViewController, animated: true, completion: nil)
                }
            }
        }

    }
}
