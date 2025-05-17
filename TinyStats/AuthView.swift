import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLogin = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            Text(isLogin ? "Sign In" : "Sign Up")
                .font(.largeTitle.bold())
                .padding(.top)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !isLogin {
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button(isLogin ? "Sign In" : "Sign Up") {
                handleAuth()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)

            Button(isLogin ? "Need an account? Sign Up" : "Have an account? Sign In") {
                isLogin.toggle()
                errorMessage = nil
            }
            .font(.footnote)
            .padding(.bottom)

            Spacer()
        }
        .padding()
    }

    func handleAuth() {
        errorMessage = nil
        if isLogin {
            signIn()
        } else {
            signUp()
        }
    }

    private func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func signUp() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else if let user = result?.user {
                // Save to Firestore
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "email": user.email ?? "",
                    "status": "pending",
                    "createdAt": FieldValue.serverTimestamp()
                ]) { err in
                    if let err = err {
                        print("Firestore error: \(err.localizedDescription)")
                    } else {
                        print("✅ User doc created with pending status")
                    }
                }
            }
        }
    }
}
