import FirebaseAuth

class AuthManager {
    static let shared = AuthManager()

    // ログイン状態を判定
    var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }

    // FirebaseAuth.UserからBlendAR2.Userに変換する
    var currentUser: User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        return User(uid: firebaseUser.uid, displayName: firebaseUser.displayName, email: firebaseUser.email, profileImageURL: firebaseUser.photoURL?.absoluteString ?? "")
    }

    // ログイン処理
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // 新規登録処理
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // ログアウト処理
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
}
