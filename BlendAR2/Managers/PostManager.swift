import FirebaseFirestore
import FirebaseStorage
import CoreLocation
import simd
import FirebaseAuth

class PostManager {
    static let shared = PostManager()

    func uploadPost(image: UIImage, location: CLLocation, completion: @escaping (Result<Void, Error>) -> Void) {
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

                self.savePostToFirestore(imageURL: downloadURL.absoluteString, location: location, completion: completion)
            }
        }
    }

    private func savePostToFirestore(imageURL: String, location: CLLocation, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(UploadError.noUserID))
            return
        }

        let post: [String: Any] = [
            "imageURL": imageURL,
            "userID": userID,
            "timestamp": Timestamp(),
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "altitude": location.altitude
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
