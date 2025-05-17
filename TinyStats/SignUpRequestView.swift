import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpRequestView: View {
    @Binding var isAuthenticated: Bool

    @State private var parentFirstName = ""
    @State private var parentLastName = ""
    @State private var childFirstName = ""
    @State private var childLastName = ""
    @State private var teamID = ""
    @State private var reason = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Team Hub")
                    .font(.largeTitle.bold())
                    .padding(.top)

                Text("Create an Account & Request Access")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Group {
                    HStack {
                        TextField("Parent First Name", text: $parentFirstName)
                        TextField("Last Name", text: $parentLastName)
                    }

                    HStack {
                        TextField("Child First Name", text: $childFirstName)
                        TextField("Last Name", text: $childLastName)
                    }

                    TextField("Team Name or Code", text: $teamID)
                    TextField("Reason for Requesting Access", text: $reason)

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
                .disableAutocorrection(true)

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button(action: handleSignUpAndRequest) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Text("Create Account & Submit Request")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    parentFirstName.isEmpty ||
                    parentLastName.isEmpty ||
                    childFirstName.isEmpty ||
                    childLastName.isEmpty ||
                    teamID.isEmpty ||
                    reason.isEmpty ||
                    email.isEmpty ||
                    password.isEmpty ||
                    confirmPassword.isEmpty
                )

                Spacer()
            }
            .padding()
        }
    }

    func handleSignUpAndRequest() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        isSubmitting = true
        errorMessage = nil

        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isSubmitting = false
                return
            }

            guard let user = result?.user else {
                self.errorMessage = "Account creation failed."
                self.isSubmitting = false
                return
            }

            let db = Firestore.firestore()
            let requestData: [String: Any] = [
                "parentName": "\(parentFirstName) \(parentLastName)",
                "childName": "\(childFirstName) \(childLastName)",
                "teamID": teamID.lowercased(),
                "reason": reason,
                "email": user.email ?? "",
                "uid": user.uid,
                "status": "pending",
                "timestamp": FieldValue.serverTimestamp()
            ]

            db.collection("joinRequests").addDocument(data: requestData) { err in
                self.isSubmitting = false
                if let err = err {
                    self.errorMessage = "Firestore error: \(err.localizedDescription)"
                } else {
                    self.clearForm()
                    self.isAuthenticated = true // ✅ triggers parent to switch views
                }
            }
        }
    }

    func clearForm() {
        parentFirstName = ""
        parentLastName = ""
        childFirstName = ""
        childLastName = ""
        teamID = ""
        reason = ""
        email = ""
        password = ""
        confirmPassword = ""
    }
}
