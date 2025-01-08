import FirebaseAuth

class LogoutManager {
    static let shared = LogoutManager()

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            AuthManager.shared.isLoggedIn = false
            AuthManager.shared.currentUser = nil
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
}
