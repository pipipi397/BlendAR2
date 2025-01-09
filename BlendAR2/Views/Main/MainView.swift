import SwiftUI
import MapKit

struct MainView: View {
    @State private var isUploadViewPresented = false
    @State private var isProfileViewPresented = false
    @State private var showActionSheet = false
    @StateObject private var viewModel = MapViewModel()

    var body: some View {
        ZStack {
            // マップ表示
            MapView(viewModel: viewModel)
                .onAppear {
                    viewModel.fetchPosts()
                }
                .edgesIgnoringSafeArea(.all)

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
                    .default(Text("プロフィール編集"), action: {
                        isProfileViewPresented = true
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
        .sheet(isPresented: $isProfileViewPresented) {
            ProfileView()
        }
    }

    // ログアウト処理
    private func logout() {
        LogoutManager.shared.logout { result in
            switch result {
            case .success:
                print("ログアウト成功")
                switchRootViewToContentView()  // ルートビューを切り替え
            case .failure(let error):
                print("ログアウトエラー: \(error.localizedDescription)")
            }
        }
    }

    // ルートビューをContentViewに変更
    private func switchRootViewToContentView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: ContentView())
            window.makeKeyAndVisible()
        }
    }
}
