import Foundation

struct User {
    var uid: String
    var displayName: String
    var email: String
    var profileImageURL: String

    // Firestoreから取得したデータを使ってUserモデルを作成
    init(uid: String, displayName: String? = nil, email: String? = nil, profileImageURL: String? = nil) {
        self.uid = uid
        self.displayName = displayName ?? "Unknown"  // デフォルト値を設定
        self.email = email ?? "No email"  // デフォルト値を設定
        self.profileImageURL = profileImageURL ?? ""  // デフォルト値を設定
    }
}
