import SwiftUI
import Firebase

struct HomeView: View {
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    @State private var followingUsers: [User] = []
    @State private var timelinePosts: [Post] = []
    @State private var errorMessage = ""
    @State private var isLoading = false // 検索中の状態を管理

    var body: some View {
        NavigationView {
            VStack {
                // プロフィールエリア
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .padding()
                    
                    VStack(alignment: .leading) {
                        Text(Auth.auth().currentUser?.displayName ?? "不明なユーザー")
                            .font(.headline)
                        Text("フォロー中: \(followingUsers.count)")
                            .font(.subheadline)
                    }
                    
                    Spacer()
                }
                .padding()

                // 検索バー
                TextField("ユーザーを検索 (displayName)", text: $searchText, onCommit: searchUser)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                // 検索結果の表示
                if isLoading {
                    ProgressView("検索中...")
                        .padding()
                } else if !searchResults.isEmpty {
                    List(searchResults, id: \.uid) { user in
                        HStack {
                            Text(user.displayName)
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                toggleFollow(user: user)
                            }) {
                                Text(isFollowing(user: user) ? "フォロー中" : "フォロー")
                                    .padding(8)
                                    .background(isFollowing(user: user) ? Color.blue : Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                } else if !searchText.isEmpty {
                    Text("該当するユーザーが見つかりません")
                        .padding()
                        .foregroundColor(.gray)
                }

                // タイムライン表示
                if !timelinePosts.isEmpty {
                    List(timelinePosts, id: \.id) { post in
                        VStack(alignment: .leading) {
                            Text(post.displayName)
                                .font(.headline)
                            Text(post.comment)
                                .font(.body)
                            Text(post.timestamp.formatted())
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    Spacer()
                    Text("タイムラインが空です")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            .navigationTitle("ホーム")
            .onAppear(perform: {
                fetchFollowingUsers()
                fetchTimelinePosts()
            })
        }
    }

    // 検索機能 (displayNameで検索)
    private func searchUser() {
        guard !searchText.isEmpty else {
            searchResults = [] // 入力が空の場合は検索結果をリセット
            return
        }

        isLoading = true // 検索中の状態を表示
        Firestore.firestore().collection("users")
            .whereField("displayName", isGreaterThanOrEqualTo: searchText)
            .whereField("displayName", isLessThanOrEqualTo: searchText + "\u{f8ff}")
            .getDocuments { snapshot, error in
                isLoading = false // 検索完了後にリセット

                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }

                guard let documents = snapshot?.documents else {
                    searchResults = [] // 結果がない場合は空配列
                    return
                }

                self.searchResults = documents.compactMap { doc in
                    try? doc.data(as: User.self)
                }

                if self.searchResults.isEmpty {
                    print("該当するユーザーが見つかりません")
                }
            }
    }

    // フォロー状態を切り替える
    private func toggleFollow(user: User) {
        if isFollowing(user: user) {
            unfollowUser(user: user)
        } else {
            followUser(user: user)
        }
    }

    // フォロー状態を確認
    private func isFollowing(user: User) -> Bool {
        followingUsers.contains(where: { $0.uid == user.uid })
    }

    // フォロー機能
    private func followUser(user: User) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(currentUserID)
            .updateData(["following": FieldValue.arrayUnion([user.uid])]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }

                // フォローしたユーザーをローカルで更新
                self.followingUsers.append(user)
            }
    }

    // アンフォロー機能
    private func unfollowUser(user: User) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(currentUserID)
            .updateData(["following": FieldValue.arrayRemove([user.uid])]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }

                // フォロー解除したユーザーをローカルで削除
                self.followingUsers.removeAll { $0.uid == user.uid }
            }
    }

    // フォローしているユーザーを取得
    private func fetchFollowingUsers() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(currentUserID)
            .getDocument { snapshot, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }

                guard let data = snapshot?.data(),
                      let followingUIDs = data["following"] as? [String] else { return }

                Firestore.firestore().collection("users")
                    .whereField("uid", in: followingUIDs)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                            return
                        }

                        self.followingUsers = snapshot?.documents.compactMap { doc in
                            try? doc.data(as: User.self)
                        } ?? []
                    }
            }
    }

    // タイムライン投稿を取得
    private func fetchTimelinePosts() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(currentUserID)
            .getDocument { snapshot, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }

                guard let data = snapshot?.data(),
                      let followingUIDs = data["following"] as? [String] else { return }

                Firestore.firestore().collection("posts")
                    .whereField("userID", in: followingUIDs)
                    .order(by: "timestamp", descending: true)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                            return
                        }

                        self.timelinePosts = snapshot?.documents.compactMap { doc in
                            try? doc.data(as: Post.self)
                        } ?? []
                    }
            }
    }
}
