import SwiftUI
import Firebase

struct PostHistoryView: View {
    @State private var posts: [Post] = []

    var body: some View {
        VStack {
            Text("投稿履歴")
                .font(.largeTitle)
                .padding()
            
            List {
                ForEach(posts) { post in
                    VStack(alignment: .leading) {
                        Text(post.imageURL)
                        Text("投稿日時: \(post.timestamp)")
                    }
                }
                .onDelete(perform: deletePost)
            }
            .onAppear {
                fetchUserPosts()
            }
        }
    }
    
    private func fetchUserPosts() {
        let userID = Auth.auth().currentUser?.uid ?? ""
        Firestore.firestore().collection("posts")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.posts = documents.map { Post(from: $0.data()) }
            }
    }
    
    private func deletePost(at offsets: IndexSet) {
        offsets.forEach { index in
            let post = posts[index]
            Firestore.firestore().collection("posts").document(post.id).delete { error in
                if let error = error {
                    print("削除に失敗しました: \(error.localizedDescription)")
                } else {
                    posts.remove(atOffsets: offsets)
                }
            }
        }
    }
}
