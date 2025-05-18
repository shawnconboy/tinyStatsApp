import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @Binding var isAuthenticated: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isSubmitting = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign In")
                .font(.title.bold())
                .padding(.top)

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button(action: signIn) {
                if isSubmitting {
                    ProgressView()
                } else {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.isEmpty)

            Spacer()
        }
        .padding()
    }

    func signIn() {
        isSubmitting = true
        errorMessage = nil

        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isSubmitting = false

            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isAuthenticated = true
            }
        }
    }
}
