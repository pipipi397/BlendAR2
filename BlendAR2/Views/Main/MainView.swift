import SwiftUI
import MapKit
import FirebaseAuth

struct MainView: View {
    @State private var isUploadViewPresented = false
    @State private var isPostHistoryViewPresented = false // 投稿履歴表示用
    @State private var showActionSheet = false
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack {
            if let currentLocation = locationManager.userLocation,
               let userID = Auth.auth().currentUser?.uid { // ログイン中のユーザーIDを取得
                MapView(viewModel: viewModel)
                    .onAppear {
                        viewModel.fetchPosts(currentLocation: currentLocation, userID: userID) // ユーザーの投稿を取得
                    }
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("位置情報を取得中...")
                    .font(.title)
                    .foregroundColor(.gray)
            }
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
                    .default(Text("ホーム"), action: { // ホームに変更
                        isPostHistoryViewPresented = true
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
        .sheet(isPresented: $isPostHistoryViewPresented) {
            PostHistoryView() // 投稿履歴を表示
        }
    }

    private func logout() {
        LogoutManager.shared.logout { result in
            switch result {
            case .success:
                print("ログアウト成功")
                switchRootViewToContentView() // ルートビューを切り替え
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
