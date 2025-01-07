import Foundation

struct User: Identifiable, Codable {
    var id: String
    var email: String
    var following: [String] = []
}
