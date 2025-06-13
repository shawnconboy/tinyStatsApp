import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var loginError: String?

    var body: some View {
        NavigationStack {
            Form {
                // Show signed-in account info at the top
                if let name = auth.adminProfile?.name ?? auth.memberProfile?.name {
                    Section {
                        HStack {
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(.gray)
                            Text("Signed in as \(name)")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section(header: Text("Account")) {
                    if auth.isSignedIn {
                        Button("Log Out") {
                            auth.signOut()
                        }

                        Text("Signed In")
                            .foregroundColor(.green)

                    } else {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textContentType(.emailAddress)

                        SecureField("Password", text: $password)
                            .textContentType(.password)

                        Button("Log In") {
                            auth.signIn(email: email, password: password) { errorMessage in
                                loginError = errorMessage
                                if errorMessage == nil {
                                    email = ""
                                    password = ""
                                }
                            }
                        }
                        .disabled(email.isEmpty || password.isEmpty)

                        if let loginError = loginError {
                            Text(loginError)
                                .foregroundColor(.red)
                                .font(.caption)
                        }

                        Text("Signed Out")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
