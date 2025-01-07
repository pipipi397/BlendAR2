import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth  // FirebaseAuthをインポート
import UIKit
import CoreLocation

class PostManager {
    static let shared = PostManager()

    private init() {}

    // 画像をFirebase Storageにアップロードし、そのURLをFirestoreに保存する処理
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "画像の変換に失敗しました"])))
            return
        }

        let storageRef = Storage.storage().reference().child("posts/\(UUID().uuidString).jpg")

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

    // Firestoreに投稿情報を保存
    func savePost(imageURL: String, location: CLLocationCoordinate2D, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "ログインユーザーがいません"])))
            return
        }

        let post = [
            "imageURL": imageURL,
            "latitude": location.latitude,
            "longitude": location.longitude,
            "userID": currentUser.uid,
            "timestamp": Timestamp(date: Date())
        ] as [String : Any]

        Firestore.firestore().collection("posts").addDocument(data: post) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))  // 投稿が成功した場合
            }
        }
    }
}
