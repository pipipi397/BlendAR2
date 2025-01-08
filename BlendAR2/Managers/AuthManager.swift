import Firebase
import FirebaseAuth
import SwiftUI

class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    private init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { _, user in
            if let user = user {
                self.currentUser = User(uid: user.uid, displayName: user.displayName ?? "", email: user.email ?? "")
                self.isLoggedIn = true
            } else {
                self.isLoggedIn = false
                self.currentUser = nil
            }
        }
    }

    // ログイン処理を追加
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        LoginManager.shared.login(email: email, password: password) { result in
            switch result {
            case .success:
                self.isLoggedIn = true
                self.currentUser = Auth.auth().currentUser.map {
                    User(uid: $0.uid, displayName: $0.displayName ?? "", email: $0.email ?? "")
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
