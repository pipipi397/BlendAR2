import FirebaseAuth
import SwiftUI

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?  // リスナーハンドルを保持

    private init() {
        // ログイン状態を監視するリスナーを登録
        authStateHandle = Auth.auth().addStateDidChangeListener { _, user in
            if let user = user {
                self.currentUser = User(from: user)
                self.isLoggedIn = true
            } else {
                self.currentUser = nil
                self.isLoggedIn = false
            }
        }
    }
    
    // ログイン処理
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let user = result?.user {
                self.currentUser = User(from: user)
                self.isLoggedIn = true
                completion(.success(()))
            }
        }
    }
    
    // 新規登録処理
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let user = result?.user {
                self.currentUser = User(from: user)
                self.isLoggedIn = true
                completion(.success(()))
            }
        }
    }
    
    // リスナーの解除（必要に応じて）
    func removeAuthListener() {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
