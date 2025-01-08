import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import UIKit
import CoreLocation

class PostManager {
    static let shared = PostManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            let error = NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "画像データの取得に失敗しました"])
            completion(.failure(error))
            return
        }
        
        let ref = Storage.storage().reference().child("posts/\(UUID().uuidString).jpg")
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            ref.downloadURL { url, error in
                if let url = url {
                    completion(.success(url.absoluteString))
                } else {
                    let error = NSError(domain: "URLFetchError", code: 0, userInfo: [NSLocalizedDescriptionKey: "ダウンロードURLの取得に失敗しました"])
                    completion(.failure(error))
                }
            }
        }
    }
    
    func savePost(imageURL: String, location: CLLocationCoordinate2D, completion: @escaping (Result<Void, Error>) -> Void) {
        let postID = UUID().uuidString
        let post = [
            "id": postID,
            "imageURL": imageURL,
            "position": [
                "latitude": location.latitude,
                "longitude": location.longitude
            ],
            "timestamp": Timestamp(date: Date()),
            "userID": Auth.auth().currentUser?.uid ?? "unknown"
        ] as [String: Any]
        
        db.collection("posts").document(postID).setData(post) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
