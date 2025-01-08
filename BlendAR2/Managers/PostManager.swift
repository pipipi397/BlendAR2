import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth  // Firebase Authentication をインポート

class PostManager: ObservableObject {
    static let shared = PostManager()

    func uploadPost(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(UploadError.invalidImage))
            return
        }

        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("posts/\(UUID().uuidString).jpg")

        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let downloadURL = url else {
                    completion(.failure(UploadError.failedToGetURL))
                    return
                }
                
                self.savePostToFirestore(imageURL: downloadURL.absoluteString, completion: completion)
            }
        }
    }

    private func savePostToFirestore(imageURL: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(UploadError.noUserID))
            return
        }

        let post: [String: Any] = [
            "imageURL": imageURL,
            "userID": userID,
            "timestamp": Timestamp()
        ]
        
        Firestore.firestore().collection("posts").addDocument(data: post) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("投稿完了"))
            }
        }
    }

    enum UploadError: Error {
        case invalidImage
        case failedToGetURL
        case noUserID
    }
}
