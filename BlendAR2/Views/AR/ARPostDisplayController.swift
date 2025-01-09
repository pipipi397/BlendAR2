import UIKit
import RealityKit
import ARKit

class ARPostDisplayController: UIViewController {
    var arView: ARView!
    var postData: [String: Any]? // 投稿データを格納

    override func viewDidLoad() {
        super.viewDidLoad()

        arView = ARView(frame: view.bounds)
        view.addSubview(arView)

        setupARSession()

        if let postData = postData {
            recreateGeoAnchor(from: postData)
        }
    }

    private func setupARSession() {
        guard ARGeoTrackingConfiguration.isSupported else {
            print("ARGeoTrackingConfigurationがサポートされていません")
            return
        }

        let configuration = ARGeoTrackingConfiguration()
        arView.session.run(configuration)
    }

    private func recreateGeoAnchor(from postData: [String: Any]) {
        guard let latitude = postData["latitude"] as? CLLocationDegrees,
              let longitude = postData["longitude"] as? CLLocationDegrees,
              let altitude = postData["altitude"] as? CLLocationDistance else {
            print("投稿データが不正です")
            return
        }

        let geoAnchor = ARGeoAnchor(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: altitude)
        arView.session.add(anchor: geoAnchor)

        let anchorEntity = AnchorEntity(anchor: geoAnchor)
        let plane = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3))
        plane.model?.materials = [SimpleMaterial(color: .green, isMetallic: false)]

        anchorEntity.addChild(plane)
        arView.scene.addAnchor(anchorEntity)
        print("ARGeoAnchorを再現しました")
    }
}
