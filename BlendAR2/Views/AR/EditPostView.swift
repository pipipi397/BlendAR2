import SwiftUI
import FirebaseFirestore

struct EditPostView: View {
    @State var post: Post
    @State private var updatedComment: String = ""
    @State private var isSaving = false
    var onSave: (Post) -> Void

    var body: some View {
        VStack {
            TextField("コメントを編集", text: $updatedComment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                saveChanges()
            }) {
                if isSaving {
                    ProgressView()
                } else {
                    Text("保存")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isSaving || updatedComment.isEmpty) // コメントが空の場合ボタンを無効化
            .padding()
        }
        .onAppear {
            updatedComment = post.comment
        }
    }

    private func saveChanges() {
        guard let postId = post.id else {
            print("投稿IDが存在しません")
            return
        }

        isSaving = true
        let updatedData: [String: Any] = [
            "comment": updatedComment,
            "timestamp": Timestamp() // 更新日時を記録
        ]

        Firestore.firestore().collection("posts").document(postId).updateData(updatedData) { error in
            isSaving = false
            if let error = error {
                print("コメント更新エラー: \(error.localizedDescription)")
            } else {
                post.comment = updatedComment
                post.timestamp = Date() // ローカルの投稿データも更新
                onSave(post) // 更新後リストをリフレッシュ
            }
        }
    }
}
