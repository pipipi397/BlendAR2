import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CoreLocation

class PostManager {
    static let shared = PostManager()

    func uploadPost(image: UIImage, userLocation: CLLocationCoordinate2D, comment: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(UploadError.invalidImage))
            return
        }

        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("posts/\(UUID().uuidString).jpg")

        imageRef.putData(imageData, metadata: nil) { _, error in
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

                self.savePostToFirestore(imageURL: downloadURL.absoluteString, userLocation: userLocation, comment: comment, completion: completion)
            }
        }
    }

    private func savePostToFirestore(imageURL: String, userLocation: CLLocationCoordinate2D, comment: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(UploadError.noUserID))
            return
        }

        let post: [String: Any] = [
            "imageURL": imageURL,
            "userID": userID,
            "timestamp": Timestamp(),
            "position": [
                "latitude": userLocation.latitude,
                "longitude": userLocation.longitude
            ],
            "comment": comment
        ]

        Firestore.firestore().collection("posts").addDocument(data: post) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    enum UploadError: Error {
        case invalidImage
        case failedToGetURL
        case noUserID
    }
}
