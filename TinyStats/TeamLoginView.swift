import SwiftUI
import Firebase

struct TeamLoginView: View {
    @Environment(\.dismiss) var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggingIn = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Login")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    SecureField("Password", text: $password)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                Button(isLoggingIn ? "Logging In..." : "Log In") {
                    login()
                }
                .disabled(isLoggingIn)
            }
            .navigationTitle("Team Login")
        }
    }

    func login() {
        errorMessage = ""
        isLoggingIn = true

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoggingIn = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                dismiss()
            }
        }
    }
}
