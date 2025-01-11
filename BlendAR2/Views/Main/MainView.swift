import SwiftUI
import MapKit
import FirebaseAuth

struct MainView: View {
    @State private var isUploadViewPresented = false
    @State private var isHomeViewPresented = false
    @State private var showActionSheet = false
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack {
            // 現在地に基づく地図表示
            if let currentLocation = locationManager.userLocation {
                MapView(viewModel: viewModel)
                    .onAppear {
                        viewModel.fetchPosts(currentLocation: currentLocation)
                    }
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("位置情報を取得中...")
                    .font(.title)
                    .foregroundColor(.gray)
            }

            // メニュー表示用ボタン
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        showActionSheet = true
                    }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding()
                    }
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("メニュー"),
                buttons: [
                    .default(Text("投稿"), action: {
                        isUploadViewPresented = true
                    }),
                    .default(Text("ホーム"), action: {
                        isHomeViewPresented = true
                    }),
                    .destructive(Text("ログアウト"), action: {
                        logout()
                    }),
                    .cancel(Text("キャンセル"))
                ]
            )
        }
        .sheet(isPresented: $isUploadViewPresented) {
            UploadView() // 投稿画面
        }
        .sheet(isPresented: $isHomeViewPresented) {
            HomeView() // ホーム画面を表示
        }
    }

    // ログアウト処理
    private func logout() {
        LogoutManager.shared.logout { result in
            switch result {
            case .success:
                print("ログアウト成功")
                switchRootViewToContentView()
            case .failure(let error):
                print("ログアウトエラー: \(error.localizedDescription)")
            }
        }
    }

    // ルートビューの切り替え
    private func switchRootViewToContentView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: ContentView())
            window.makeKeyAndVisible()
        }
    }
}
