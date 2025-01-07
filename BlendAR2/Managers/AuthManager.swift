import Firebase
import FirebaseFirestore
import SwiftUI

class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    private init() {
        // 認証状態のリスナーを追加
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

    // ログイン処理
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))  // エラーがあれば返す
                return
            }
            self.isLoggedIn = true
            self.currentUser = User(uid: result?.user.uid ?? "", displayName: result?.user.displayName ?? "", email: result?.user.email ?? "")
            completion(.success(()))  // ログイン成功
        }
    }

    // ログアウト処理
    func logout() {
        do {
            try Auth.auth().signOut()  // Firebaseからサインアウト
            self.isLoggedIn = false
            self.currentUser = nil
        } catch {
            print("ログアウトに失敗しました: \(error.localizedDescription)")
        }
    }
}
