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
        uiView.removeAnnotations(uiView.annotations) // 既存のピンを削除
        uiView.addAnnotations(viewModel.annotations) // 新しいピンを追加
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
            guard let annotation = view.annotation as? MKPointAnnotation,
                  let comment = annotation.title,
                  let imageURL = annotation.subtitle else {
                print("ピン情報が不十分です")
                return
            }

            // コメントを表示するアラートを作成
            let alert = UIAlertController(title: "投稿詳細", message: comment, preferredStyle: .alert)

            // アラートに「閉じる」ボタンを追加
            alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))

            // アラートに「ARで表示」ボタンを追加
            alert.addAction(UIAlertAction(title: "ARで表示", style: .default) { _ in
                if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                    let arPostViewController = ARPostDisplayController()
                    arPostViewController.postData = ["imageURL": imageURL]
                    rootViewController.present(arPostViewController, animated: true, completion: nil)
                }
            })

            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true, completion: nil)
            }
        }
    }
}
