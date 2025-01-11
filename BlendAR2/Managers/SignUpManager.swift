import Firebase
import FirebaseFirestore

class SignUpManager {
    static let shared = SignUpManager()

    private init() {}

    func signUp(email: String, password: String, displayName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let user = result?.user {
                self.saveUserProfile(uid: user.uid, email: email, displayName: displayName) { success in
                    if success {
                        completion(.success(()))
                    } else {
                        completion(.failure(NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "ユーザープロフィールの保存に失敗しました"])))
                    }
                }
            }
        }
    }

    func saveUserProfile(uid: String, email: String, displayName: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "uid": uid,
            "displayName": displayName,
            "email": email,
            "profileImageURL": "" // 初期値
        ]) { error in
            if let error = error {
                print("ユーザー情報の保存に失敗: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
