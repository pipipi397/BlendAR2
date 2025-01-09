import Foundation
import RealityKit
import ARKit

class MapManager {
    static let shared = MapManager()

    func recreateAnchor(from postData: [String: Any], arView: ARView) {
        guard let latitude = postData["latitude"] as? CLLocationDegrees,
              let longitude = postData["longitude"] as? CLLocationDegrees,
              let altitude = postData["altitude"] as? CLLocationDistance else {
            print("位置データが不正です")
            return
        }

        let geoAnchor = ARGeoAnchor(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: altitude)
        arView.session.add(anchor: geoAnchor)

        let anchorEntity = AnchorEntity(anchor: geoAnchor)

        let plane = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3))
        plane.model?.materials = [SimpleMaterial(color: .green, isMetallic: false)]
        anchorEntity.addChild(plane)

        arView.scene.addAnchor(anchorEntity)
        print("GeoAnchorを再現しました")
    }
}
