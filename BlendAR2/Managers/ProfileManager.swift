import Firebase
import FirebaseStorage
import UIKit

class ProfileManager {
    static let shared = ProfileManager()

    private init() {}

    // プロフィール画像をアップロードする処理
    func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "画像の変換に失敗しました"])))
            return
        }

        let storageRef = Storage.storage().reference().child("profile_images/\(UUID().uuidString).jpg")

        // StorageMetadataを使用
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let downloadURL = url {
                    completion(.success(downloadURL.absoluteString))  // ダウンロードURLを返す
                }
            }
        }
    }

    // ユーザープロフィールをFirestoreに更新する処理
    func updateUserProfile(uid: String, displayName: String, profileImageURL: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        var data: [String: Any] = [
            "displayName": displayName
        ]

        if let profileImageURL = profileImageURL {
            data["profileImageURL"] = profileImageURL
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).updateData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))  // プロフィール更新成功
            }
        }
    }
}
