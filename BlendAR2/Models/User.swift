import FirebaseAuth

struct User: Identifiable {
    var id: String
    var email: String?

    // FirebaseAuth.Userから初期化するイニシャライザを追加
    init(from firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email
    }
}
