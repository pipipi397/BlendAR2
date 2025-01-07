import SwiftUI
import MapKit
import CoreLocation

// Equatableに準拠したCoordinate型を作成
struct Coordinate: Equatable {
    var latitude: Double
    var longitude: Double

    // CLLocationCoordinate2Dを簡単に変換できるようにする
    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct MainView: View {
    @StateObject private var locationManager = LocationManager()  // LocationManagerを使って位置情報を管理
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503), // 初期位置を東京に設定
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var userLocation: Coordinate? = nil  // Coordinate型を使用
    @State private var showPostButton = false
    @State private var showARView = false
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, showsUserLocation: true)
                .onAppear {
                    if let userLocation = locationManager.userLocation {
                        self.userLocation = Coordinate(coordinate: userLocation)
                        region.center = userLocation
                    }
                }
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        self.showPostButton.toggle()
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
                        self.showARView.toggle()
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
        .onChange(of: userLocation) { newLocation in
            if let location = newLocation {
                region.center = location.toCLLocationCoordinate2D()  // 位置が更新されるたびに地図の中心を更新
            }
        }
    }
}
