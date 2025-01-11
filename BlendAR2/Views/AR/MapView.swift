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
        uiView.removeAnnotations(uiView.annotations) // 現在のピンを削除
        uiView.addAnnotations(viewModel.annotations) // 新しいピンを追加
        print("更新されたピン数: \(viewModel.annotations.count)")
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
            guard let annotation = view.annotation as? MKPointAnnotation else {
                print("選択されたピンが無効です")
                return
            }

            print("選択されたピン情報:")
            print("タイトル: \(annotation.title ?? "なし")")
            print("URL: \(annotation.subtitle ?? "なし")")

            guard let comment = annotation.title,
                  let imageURL = annotation.subtitle else {
                print("ピン情報が不足しています")
                return
            }

            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                let arPostController = ARPostDisplayController()
                arPostController.postData = ["comment": comment, "imageURL": imageURL]
                rootViewController.present(arPostController, animated: true)
            }
        }
    }
}
