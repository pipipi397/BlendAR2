import FirebaseAuth

class LogoutManager {
    static let shared = LogoutManager()

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        AuthManager.shared.logout { result in
            switch result {
            case .success:
                print("ログアウト成功")
                completion(.success(()))  // ログアウト成功
            case .failure(let error):
                completion(.failure(error))  // エラー処理
            }
        }
    }
}
