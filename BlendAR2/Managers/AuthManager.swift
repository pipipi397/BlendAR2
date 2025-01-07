import FirebaseAuth

class AuthManager {
    static let shared = AuthManager()
    
    // 新規登録 (既存)
    func signUp(email: String, password: String, userID: String, completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let user = result?.user {
                completion(.success(user))
            }
        }
    }
    
    // **ログインメソッドを追加**
    func login(email: String, password: String, completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let user = result?.user {
                completion(.success(user))
            }
        }
    }
}
