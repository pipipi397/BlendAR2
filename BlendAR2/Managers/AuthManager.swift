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
    
    // ログアウト処理
    func logout() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.currentUser = nil
            resetToLoginView()
        } catch {
            print("ログアウトに失敗しました: \(error.localizedDescription)")
        }
    }
    
    // 初期画面（ログイン画面）に戻る処理
    private func resetToLoginView() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first })
            .first else {
            return
        }
        
        window.rootViewController = UIHostingController(rootView: LoginView())
        window.makeKeyAndVisible()
    }
}
