import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct PostHistoryView: View {
    @State private var posts: [Post] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(posts) { post in
                    VStack(alignment: .leading) {
                        Text(post.comment)
                            .font(.headline)
                        Text("位置: \(post.position.latitude), \(post.position.longitude)")
                            .font(.subheadline)
                        Text("投稿日時: \(post.timestamp)")
                            .font(.subheadline)
                    }
                }
                .onDelete(perform: deletePost)
            }
            .navigationBarTitle("投稿履歴", displayMode: .inline)
        }
        .onAppear {
            fetchUserPosts()
        }
    }

    private func fetchUserPosts() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("posts")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Firestoreエラー: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                self.posts = documents.map { doc in
                    var post = Post(from: doc.data())
                    post.id = doc.documentID
                    return post
                }
            }
    }

    private func deletePost(at offsets: IndexSet) {
        offsets.forEach { index in
            let post = posts[index]
            Firestore.firestore().collection("posts").document(post.id).delete { error in
                if let error = error {
                    print("Firestore投稿削除エラー: \(error.localizedDescription)")
                } else {
                    let storageRef = Storage.storage().reference(forURL: post.imageURL)
                    storageRef.delete { error in
                        if let error = error {
                            print("Storage画像削除エラー: \(error.localizedDescription)")
                        } else {
                            print("投稿と画像の削除に成功")
                            self.posts.remove(at: index)
                        }
                    }
                }
            }
        }
    }
}
