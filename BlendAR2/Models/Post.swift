import Foundation
import CoreLocation

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
        
        func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    // Postを辞書型に変換するメソッド
    func toDictionary() -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(self)
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            return dictionary ?? [:]
        } catch {
            print("Failed to encode Post: \(error.localizedDescription)")
            return [:]
        }
    }
}
