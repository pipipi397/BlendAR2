import SwiftUI
import MapKit
import FirebaseAuth

struct MainView: View {
    @State private var isUploadViewPresented = false
    @State private var isHomeViewPresented = false
    @State private var isARViewPresented = false
    @State private var showActionSheet = false
    @State private var selectedPost: Post?
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var currentLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    var body: some View {
        ZStack {
            if let userLocation = locationManager.userLocation {
                MapView(viewModel: viewModel, currentLocation: $currentLocation)
                    .onAppear {
                        currentLocation = userLocation
                        viewModel.fetchPosts(currentLocation: userLocation)
                    }
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("位置情報を取得中...")
                    .font(.title)
                    .foregroundColor(.gray)
            }
            VStack {
                Spacer()

                // ARボタン
                if let selectedPost = selectedPost {
                    Button(action: {
                        isARViewPresented = true
                    }) {
                        Text("ARで投稿を見る")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    .sheet(isPresented: $isARViewPresented) {
                        ARPostDisplayControllerWrapper(post: selectedPost)
                    }
                }

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
            UploadView()
        }
        .sheet(isPresented: $isHomeViewPresented) {
            HomeView() // ホーム画面への遷移を実現
        }
    }

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

    private func switchRootViewToContentView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: ContentView())
            window.makeKeyAndVisible()
        }
    }
}

struct ARPostDisplayControllerWrapper: UIViewControllerRepresentable {
    let post: Post

    func makeUIViewController(context: Context) -> ARPostDisplayController {
        let controller = ARPostDisplayController()
        controller.postData = ["comment": post.comment, "imageURL": post.imageURL]
        return controller
    }

    func updateUIViewController(_ uiViewController: ARPostDisplayController, context: Context) {}
}
