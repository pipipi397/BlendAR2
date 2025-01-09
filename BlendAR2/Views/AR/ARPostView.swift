import SwiftUI
import RealityKit
import ARKit
import FirebaseFirestore

struct ARPostView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ARViewContainer()
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                locationManager.requestLocationPermission()
            }
            .overlay(
                VStack {
                    Spacer()
                    Button(action: addLocationAnchor) {
                        Text("アンカーを追加")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            )
    }

    private func addLocationAnchor() {
        guard let location = locationManager.userLocation else {
            print("現在地を取得できません")
            return
        }

        let geoAnchor = ARGeoAnchor(coordinate: location.coordinate, altitude: location.altitude)
        ARViewContainer.sharedARView.session.add(anchor: geoAnchor)

        savePostToFirestore(location: location)
    }

    private func savePostToFirestore(location: CLLocation) {
        let postData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "altitude": location.altitude,
            "timestamp": Date()
        ]

        Firestore.firestore().collection("posts").addDocument(data: postData) { error in
            if let error = error {
                print("Firestoreへの保存に失敗: \(error.localizedDescription)")
            } else {
                print("Firestoreへの保存に成功")
            }
        }
    }
}
