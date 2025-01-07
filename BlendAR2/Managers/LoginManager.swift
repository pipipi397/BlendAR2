import Firebase

class LoginManager {
    static let shared = LoginManager()

    private init() {}
    
    // ログイン処理
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))  // エラーがあれば返す
                return
            }
            if let _ = result?.user {
                completion(.success(()))  // ログイン成功
            }
        }
    }
}

