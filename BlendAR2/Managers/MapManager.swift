import Foundation
import MapKit
import SwiftUI

class MapManager {
    static let shared = MapManager()

    private init() {}

    // 地図のカスタム設定
    func createMapRegion(center: CLLocationCoordinate2D) -> MKCoordinateRegion {
        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }

    // 現在地のみを表示するための地図設定
    func createMapView(region: Binding<MKCoordinateRegion>) -> some View {
        return Map(coordinateRegion: region, showsUserLocation: true) // 現在地のみを表示
            .edgesIgnoringSafeArea(.all)
    }
}
