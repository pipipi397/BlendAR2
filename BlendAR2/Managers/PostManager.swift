import FirebaseFirestore
import FirebaseStorage
import UIKit
import CoreLocation

class PostManager {
    static let shared = PostManager()

    private init() {}

    func uploadPost(
        image: UIImage,
        userLocation: CLLocationCoordinate2D,
        comment: String,
        userID: String,
        displayName: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        let postID = UUID().uuidString

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "InvalidImageData", code: 0, userInfo: nil)))
            return
        }

        let imageRef = storage.reference().child("posts/\(postID).jpg")
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

                guard let imageURL = url?.absoluteString else {
                    completion(.failure(NSError(domain: "InvalidImageURL", code: 0, userInfo: nil)))
                    return
                }

                let postData: [String: Any] = [
                    "imageURL": imageURL,
                    "position": GeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude),
                    "timestamp": Timestamp(),
                    "comment": comment,
                    "userID": userID,
                    "displayName": displayName
                ]

                db.collection("posts").document(postID).setData(postData) { error in
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
