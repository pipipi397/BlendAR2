import Firebase
import FirebaseFirestore

class SignUpManager {
    static let shared = SignUpManager()

    private init() {}

    // 新規登録処理
    func signUp(email: String, password: String, displayName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))  // エラーがあれば返す
                return
            }

            if let user = result?.user {
                // 新規登録後にユーザープロフィールをFirestoreに保存
                self.saveUserProfile(uid: user.uid, displayName: displayName) { success in
                    if success {
                        completion(.success(()))  // サインアップ成功
                    } else {
                        completion(.failure(NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "ユーザープロフィールの保存に失敗しました"])))
                    }
                }
            }
        }
    }

    // Firestoreにユーザー情報を保存
    func saveUserProfile(uid: String, displayName: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "displayName": displayName,
            "email": "", // 必要なフィールドを追加
            "profileImageURL": ""
        ]) { error in
            if let error = error {
                print("ユーザー情報の保存に失敗: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true) // ユーザー情報保存成功
            }
        }
    }
}
