import SwiftUI

struct PostDetailView: View {
    var post: Post

    var body: some View {
        VStack {
            // 投稿の画像表示
            if let url = URL(string: post.imageURL) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 300)
            } else {
                Text("画像を読み込めませんでした")
                    .foregroundColor(.gray)
            }


            // コメント表示
            Text(post.comment)
                .font(.title2)
                .padding()

            // 投稿者ID表示
            Text("投稿者: \(post.userID)")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding()

            // 投稿日時表示
            Text("投稿日: \(post.timestamp.formatted())")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding()

            Spacer()
        }
        .navigationTitle("投稿の詳細")
        .padding()
    }
}
