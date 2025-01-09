import FirebaseFirestore
import FirebaseStorage
import CoreLocation
import simd
import FirebaseAuth

class PostManager {
    static let shared = PostManager()

    func uploadPost(image: UIImage, arAnchorPosition: simd_float4x4, userLocation: CLLocationCoordinate2D, completion: @escaping (Result<Void, Error>) -> Void) {
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

                self.savePostToFirestore(imageURL: downloadURL.absoluteString, arAnchorPosition: arAnchorPosition, userLocation: userLocation, completion: completion)
            }
        }
    }

    private func savePostToFirestore(imageURL: String, arAnchorPosition: simd_float4x4, userLocation: CLLocationCoordinate2D, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(UploadError.noUserID))
            return
        }

        // 修正: Float を Double に変換して配列を作成
        let arAnchorPositionDict: [String: [Double]] = [
            "column0": [Double(arAnchorPosition.columns.0.x), Double(arAnchorPosition.columns.0.y), Double(arAnchorPosition.columns.0.z), Double(arAnchorPosition.columns.0.w)],
            "column1": [Double(arAnchorPosition.columns.1.x), Double(arAnchorPosition.columns.1.y), Double(arAnchorPosition.columns.1.z), Double(arAnchorPosition.columns.1.w)],
            "column2": [Double(arAnchorPosition.columns.2.x), Double(arAnchorPosition.columns.2.y), Double(arAnchorPosition.columns.2.z), Double(arAnchorPosition.columns.2.w)],
            "column3": [Double(arAnchorPosition.columns.3.x), Double(arAnchorPosition.columns.3.y), Double(arAnchorPosition.columns.3.z), Double(arAnchorPosition.columns.3.w)]
        ]

        let post: [String: Any] = [
            "imageURL": imageURL,
            "userID": userID,
            "timestamp": Timestamp(),
            "position": [
                "latitude": userLocation.latitude,
                "longitude": userLocation.longitude
            ],
            "arAnchorPosition": arAnchorPositionDict
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
