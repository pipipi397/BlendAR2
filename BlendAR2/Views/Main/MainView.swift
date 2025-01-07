import SwiftUI
import MapKit
import CoreLocation

struct MainView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // 初期位置（例: サンフランシスコ）
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var userLocation: CLLocationCoordinate2D? = nil
    @State private var showPostButton = false
    @State private var showARView = false
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, showsUserLocation: true)
                .onAppear {
                    getCurrentLocation()
                }
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showPostButton.toggle()
                    }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
                Spacer()
                if showPostButton {
                    Button(action: {
                        showARView.toggle()
                    }) {
                        Text("画像投稿")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }

            if showARView {
                ARPostView(selectedImage: $selectedImage)
            }
        }
    }

    func getCurrentLocation() {
        guard let location = CLLocationManager().location else { return }
        userLocation = location.coordinate
        region.center = userLocation ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)  // デフォルト位置
    }
}
