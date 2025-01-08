import Foundation
import CoreLocation
import FirebaseFirestore

struct Post: Identifiable, Codable {
    var id: String = UUID().uuidString
    var imageURL: String
    var position: Coordinate
    var timestamp: Date
    
    struct Coordinate: Codable {
        var latitude: Double
        var longitude: Double
        
        init(from location: CLLocationCoordinate2D) {
            self.latitude = location.latitude
            self.longitude = location.longitude
        }
        
        init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
        
        func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    init(from data: [String: Any]) {
        self.id = data["id"] as? String ?? UUID().uuidString
        self.imageURL = data["imageURL"] as? String ?? ""
        
        if let positionData = data["position"] as? [String: Any],
           let latitude = positionData["latitude"] as? Double,
           let longitude = positionData["longitude"] as? Double {
            self.position = Coordinate(latitude: latitude, longitude: longitude)
        } else {
            self.position = Coordinate(latitude: 0.0, longitude: 0.0)
        }
        
        if let timestamp = data["timestamp"] as? Timestamp {
            self.timestamp = timestamp.dateValue()
        } else {
            self.timestamp = Date()
        }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "imageURL": imageURL,
            "position": [
                "latitude": position.latitude,
                "longitude": position.longitude
            ],
            "timestamp": Timestamp(date: timestamp)
        ]
    }
}
