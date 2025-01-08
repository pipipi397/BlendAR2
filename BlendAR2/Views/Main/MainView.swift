import SwiftUI

struct MainView: View {
    @State private var showActionSheet = false
    @State private var navigateToUpload = false
    
    var body: some View {
        NavigationView {
            ZStack {
                MapView()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    Text("現在地が表示されます")
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                }
                
                // 左上のアイコン
                VStack {
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
                    Spacer()
                }
                
                // 投稿画面へのナビゲーションリンク
                NavigationLink(
                    destination: UploadView(),
                    isActive: $navigateToUpload,
                    label: { EmptyView() }
                )
            }
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("メニューを選択"),
                buttons: [
                    .default(Text("画像の投稿"), action: {
                        navigateToUpload = true
                    }),
                    .default(Text("プロフィール編集"), action: {
                        openProfileView()
                    }),
                    .cancel(Text("キャンセル"))
                ]
            )
        }
    }
    
    // プロフィール編集画面の呼び出し
    private func openProfileView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let profileView = UIHostingController(rootView: ProfileView())
            window.rootViewController?.present(profileView, animated: true, completion: nil)
        }
    }
}
