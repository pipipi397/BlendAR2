import SwiftUI
import RealityKit
import ARKit

struct ARDrawingView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ARDrawingControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack {
                    Spacer()
                    Button("完了") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                }
            )
    }
}
