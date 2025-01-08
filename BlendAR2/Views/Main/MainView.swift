import SwiftUI
import MapKit

struct MainView: View {
    @State private var isUploadViewPresented = false
    @State private var isProfileViewPresented = false
    @State private var isLoggedOut = false

    var body: some View {
        NavigationView {
            ZStack {
                MapView() // マップ表示
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            showActionSheet()
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
            .sheet(isPresented: $isUploadViewPresented) {
                UploadView()
            }
            .sheet(isPresented: $isProfileViewPresented) {
                ProfileView()
            }
        }
    }
    
    // メニューのアクションシート
    private func showActionSheet() {
        let actionSheet = UIAlertController(title: "メニュー", message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "投稿", style: .default, handler: { _ in
            isUploadViewPresented = true
        }))

        actionSheet.addAction(UIAlertAction(title: "プロフィール編集", style: .default, handler: { _ in
            isProfileViewPresented = true
        }))

        actionSheet.addAction(UIAlertAction(title: "ログアウト", style: .destructive, handler: { _ in
            isLoggedOut = true
        }))

        actionSheet.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(actionSheet, animated: true)
        }
    }
}
