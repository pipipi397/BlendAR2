import Foundation
import CoreLocation
import FirebaseFirestore

struct Post: Identifiable {
    var id: String
    var imageURL: String
    var position: CLLocationCoordinate2D
    var timestamp: Date
    var comment: String
    var userID: String

    init(from data: [String: Any]) {
        self.id = data["id"] as? String ?? UUID().uuidString
        self.imageURL = data["imageURL"] as? String ?? ""
        
        if let positionData = data["position"] as? [String: Double],
           let latitude = positionData["latitude"],
           let longitude = positionData["longitude"] {
            self.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            self.position = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        }

        if let timestamp = data["timestamp"] as? Timestamp {
            self.timestamp = timestamp.dateValue()
        } else {
            self.timestamp = Date()
        }

        self.comment = data["comment"] as? String ?? ""
        self.userID = data["userID"] as? String ?? ""
    }
}
