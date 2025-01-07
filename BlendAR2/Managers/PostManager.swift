import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import CoreLocation

class PostManager {
    static let shared = PostManager()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func uploadPost(image: UIImage, position: CLLocationCoordinate2D, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "画像の変換に失敗しました"])))
            return
        }
        
        let storageRef = storage.reference().child("posts/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "URL取得失敗", code: 0, userInfo: nil)))
                    return
                }
                
                // CLLocationCoordinate2DをPost.Coordinateに変換
                let post = Post(
                    imageURL: downloadURL.absoluteString,
                    position: Post.Coordinate(from: position),
                    timestamp: Date()
                )
                
                self.db.collection("posts").document(post.id).setData(post.toDictionary()) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
}
