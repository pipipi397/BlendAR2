import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel
    @Binding var currentLocation: CLLocationCoordinate2D

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

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
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

            print("選択されたピン情報: \(annotation.title ?? "なし")")

            if let comment = annotation.title,
               let imageURL = annotation.subtitle {
                if let post = parent.viewModel.posts.first(where: { $0.comment == comment && $0.imageURL == imageURL }) {
                    if parent.viewModel.following.contains(post.userID) {
                        let arPostController = ARPostDisplayController()
                        arPostController.postData = ["comment": comment, "imageURL": imageURL]
                        UIApplication.shared.windows.first?.rootViewController?.present(arPostController, animated: true)
                    } else {
                        print("フォローしていないユーザーの投稿です")
                    }
                }
            }
        }
    }
}
