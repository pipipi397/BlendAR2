import SwiftUI
import FirebaseFirestore
import SDWebImageSwiftUI
import FirebaseAuth

struct PostHistoryView: View {
    @State private var posts: [Post] = [] // 投稿データ
    @State private var selectedPost: Post? = nil // 選択された投稿
    @State private var isEditing = false // 編集画面表示状態
    @State private var isLoading = false // ローディング状態

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("データを取得中...")
                        .padding()
                } else if posts.isEmpty {
                    Text("投稿がありません")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(posts) { post in
                        HStack {
                            // サムネイル画像
                            if let imageURL = URL(string: post.imageURL) {
                                WebImage(url: imageURL)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                                    .clipped()
                            }

                            VStack(alignment: .leading) {
                                Text(post.comment)
                                    .font(.headline)
                                    .lineLimit(1)

                                Text(post.timestamp, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            // 編集メニュー
                            Menu {
                                Button("編集") {
                                    selectedPost = post
                                    isEditing = true
                                }
                                Button("削除", role: .destructive) {
                                    deletePost(post)
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPost = post
                            isEditing = true // 投稿タップで編集画面を表示
                        }
                    }
                }
            }
            .navigationTitle("投稿履歴")
            .onAppear {
                fetchUserPosts()
            }
        }
        .sheet(item: $selectedPost) { post in
            PostDetailView(post: post) // 'onSave'引数を削除
        }
    }

    private func fetchUserPosts() {
        isLoading = true
        guard let userID = Auth.auth().currentUser?.uid else {
            print("ログインユーザーIDが取得できません")
            isLoading = false
            return
        }

        Firestore.firestore().collection("posts")
            .whereField("userID", isEqualTo: userID)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                isLoading = false
                if let error = error {
                    print("Firestoreエラー: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("Firestoreからの投稿データが空です")
                    return
                }

                DispatchQueue.main.async {
                    print("取得した投稿数: \(documents.count)")
                    self.posts = documents.compactMap { doc in
                        try? doc.data(as: Post.self) // FirestoreデータをPostモデルにデコード
                    }
                }
            }
    }

    private func deletePost(_ post: Post) {
        guard let postID = post.id else { return }
        Firestore.firestore().collection("posts").document(postID).delete { error in
            if let error = error {
                print("Firestore投稿削除エラー: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.posts.removeAll { $0.id == post.id }
                }
            }
        }
    }

    private func updatePost(_ updatedPost: Post) {
        if let index = posts.firstIndex(where: { $0.id == updatedPost.id }) {
            posts[index] = updatedPost
        }
    }
}
