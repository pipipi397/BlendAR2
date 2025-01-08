import SwiftUI
import MapKit

struct MainView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var showMenu = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(coordinateRegion: $region, showsUserLocation: true)
                .onAppear {
                    if let userLocation = locationManager.userLocation {
                        updateRegion(for: userLocation)
                    }
                }
                .edgesIgnoringSafeArea(.all)
            
            Button(action: {
                showMenu.toggle()
            }) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding()
            }
            .contextMenu {
                Button(action: {
                    showUploadView()
                }) {
                    Label("写真を投稿", systemImage: "plus")
                }
                
                Button(action: {
                    showProfileView()
                }) {
                    Label("プロフィールを編集", systemImage: "person.crop.circle")
                }
                
                Button(action: {
                    logout()
                }) {
                    Label("ログアウト", systemImage: "arrow.backward")
                }
            }
        }
    }
    
    private func updateRegion(for location: CLLocationCoordinate2D) {
        region.center = location
    }
    
    private func showUploadView() {
        // 写真投稿画面へ遷移するロジック
    }
    
    private func showProfileView() {
        // プロフィール編集画面へ遷移するロジック
    }
    
    private func logout() {
        LogoutManager.shared.logout { result in
            switch result {
            case .success:
                print("ログアウト成功")
                AuthManager.shared.isLoggedIn = false
            case .failure(let error):
                print("ログアウト失敗: \(error.localizedDescription)")
            }
        }
    }
}
