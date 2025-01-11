import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String? // FirestoreのドキュメントID（自動設定）
    var uid: String
    var displayName: String
    var email: String
    var profileImageURL: String

    // 初期化処理（Firestoreから取得したデータ用）
    init(uid: String, displayName: String? = nil, email: String? = nil, profileImageURL: String? = nil) {
        self.uid = uid
        self.displayName = displayName ?? "Unknown"  // デフォルト値
        self.email = email ?? "No email"  // デフォルト値
        self.profileImageURL = profileImageURL ?? ""  // デフォルト値
    }

    // Firestoreのフィールド名と一致させるためのCodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case uid
        case displayName
        case email
        case profileImageURL
    }
}
