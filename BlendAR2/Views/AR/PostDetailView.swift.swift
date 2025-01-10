import SwiftUI
import FirebaseFirestore
import SDWebImageSwiftUI

struct PostDetailView: View {
    @State var post: Post
    @State private var updatedComment: String = ""
    @State private var isSaving = false
    var onSave: (Post) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let imageURL = URL(string: post.imageURL) {
                    WebImage(url: imageURL)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(8)
                }

                TextField("コメントを編集", text: $updatedComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: saveChanges) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("保存")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(isSaving || updatedComment.isEmpty)

                Spacer()
            }
            .padding()
            .onAppear {
                updatedComment = post.comment
            }
            .navigationTitle("詳細")
        }
    }

    private func saveChanges() {
        isSaving = true
        let updatedData: [String: Any] = ["comment": updatedComment]

        Firestore.firestore().collection("posts").document(post.id).updateData(updatedData) { error in
            isSaving = false
            if let error = error {
                print("コメント更新エラー: \(error.localizedDescription)")
            } else {
                post.comment = updatedComment
                onSave(post)
            }
        }
    }
}
