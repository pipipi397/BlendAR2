import SwiftUI

@main
struct BlendAR2App: App {
    @StateObject private var authManager = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                MainView()
            } else {
                LoginView()
            }
        }
    }
}

