import SwiftUI

struct SigninView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Sign In") {
                AuthManager.shared.signIn(email: email, password: password) { success, error in
                    if success {
                        print("Sign in successful")
                    } else {
                        errorMessage = error?.localizedDescription ?? "Unknown error"
                    }
                }
            }
            .padding()
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
    }
}
