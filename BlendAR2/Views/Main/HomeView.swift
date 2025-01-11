import SwiftUI
import Firebase

struct HomeView: View {
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    @State private var followingUsers: [User] = []
    @State private var timelinePosts: [Post] = [] // タイムラインに表示する投稿
    @State private var showFollowingList = false // フォロー一覧を表示するかどうか
    @State private var errorMessage = ""

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
                        Text(Auth.auth().currentUser?.displayName ?? "ユーザー名不明") // 現在のユーザーのdisplayNameを表示
                            .font(.headline)
                        Text("フォロー中: \(followingUsers.count) | フォロワー: 28") // フォロー数はダミー値
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // プロフィール編集画面を表示
                    }) {
                        Text("プロフィールを編集")
                            .font(.caption)
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()

                // 検索バー
                TextField("ユーザーを検索 (displayName)", text: $searchText, onCommit: searchUser)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // 検索結果の表示
                if !searchResults.isEmpty {
                    List(searchResults, id: \.uid) { user in
                        HStack {
                            Text(user.displayName)
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                followUser(user: user)
                            }) {
                                Text("フォロー")
                                    .padding(8)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                // フォロー一覧ボタン
                Button(action: {
                    showFollowingList.toggle()
                }) {
                    Text("フォロー一覧")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .sheet(isPresented: $showFollowingList) {
                    FollowingListView(users: followingUsers)
                }

                // タイムライン表示
                if !timelinePosts.isEmpty {
                    List(timelinePosts, id: \.id) { post in
                        VStack(alignment: .leading) {
                            Text(post.displayName ?? "Unknown") // 動的に取得したdisplayNameを表示
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
        Firestore.firestore().collection("users")
            .whereField("displayName", isGreaterThanOrEqualTo: searchText)
            .whereField("displayName", isLessThanOrEqualTo: searchText + "\u{f8ff}")
            .getDocuments { snapshot, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }

                self.searchResults = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: User.self)
                } ?? []
            }
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

                        let posts = snapshot?.documents.compactMap { doc in
                            try? doc.data(as: Post.self)
                        } ?? []

                        // 投稿に紐づくdisplayNameを取得
                        let userIDs = Set(posts.map { $0.userID })
                        fetchUserDisplayNames(for: userIDs) { userDisplayNames in
                            self.timelinePosts = posts.map { post in
                                var updatedPost = post
                                updatedPost.displayName = userDisplayNames[post.userID] ?? "Unknown"
                                return updatedPost
                            }
                        }
                    }
            }
    }

    // ユーザー名を取得
    private func fetchUserDisplayNames(for userIDs: Set<String>, completion: @escaping ([String: String]) -> Void) {
        Firestore.firestore().collection("users")
            .whereField("uid", in: Array(userIDs))
            .getDocuments { snapshot, error in
                if let error = error {
                    print("ユーザー名取得エラー: \(error.localizedDescription)")
                    completion([:]) // エラー時は空の辞書を返す
                    return
                }

                let userDisplayNames = snapshot?.documents.reduce(into: [String: String]()) { result, doc in
                    if let user = try? doc.data(as: User.self) {
                        result[user.uid] = user.displayName
                    }
                } ?? [:]

                completion(userDisplayNames)
            }
    }
}

struct FollowingListView: View {
    let users: [User]

    var body: some View {
        List(users, id: \.uid) { user in
            Text(user.displayName)
                .font(.headline)
        }
        .navigationTitle("フォロー一覧")
    }
}
