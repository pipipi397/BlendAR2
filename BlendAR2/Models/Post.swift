import Foundation
import FirebaseFirestore
import CoreLocation

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    var imageURL: String
    var position: GeoPoint
    var timestamp: Date
    var comment: String
    var userID: String
    var displayName: String // 新たに追加

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case imageURL
        case position
        case timestamp
        case comment
        case userID
        case displayName
    }
}
