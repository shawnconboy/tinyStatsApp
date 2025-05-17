import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct JoinRequestView: View {
    @State private var parentName = ""
    @State private var childName = ""
    @State private var teamID = ""
    @State private var reason = ""
    @State private var submissionSuccess = false
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var email: String {
        Auth.auth().currentUser?.email ?? "unknown"
    }

    var body: some View {
        VStack(spacing: 16) {
            if submissionSuccess {
                VStack(spacing: 12) {
                    Text("✅ Request Submitted")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                    Text("Your request to join a team has been submitted. Please wait for admin approval.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
            } else {
                Group {
                    TextField("Parent Name", text: $parentName)
                    TextField("Child Name", text: $childName)
                    TextField("Team Name or Code", text: $teamID)
                    TextField("Reason for Requesting Access", text: $reason)
                    TextField("Email", text: .constant(email))
                        .disabled(true)
                        .foregroundColor(.gray)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
                .disableAutocorrection(true)

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button(action: submitRequest) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Text("Submit Request")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    parentName.isEmpty ||
                    childName.isEmpty ||
                    teamID.isEmpty ||
                    reason.isEmpty
                )
            }

            Spacer()
        }
        .padding()
    }

    func submitRequest() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "You must be signed in."
            return
        }

        isSubmitting = true
        errorMessage = nil

        let db = Firestore.firestore()
        let data: [String: Any] = [
            "parentName": parentName,
            "childName": childName,
            "teamID": teamID.lowercased(),
            "reason": reason,
            "email": currentUser.email ?? "",
            "uid": currentUser.uid,
            "status": "pending",
            "timestamp": FieldValue.serverTimestamp()
        ]

        db.collection("joinRequests").addDocument(data: data) { error in
            isSubmitting = false
            if let error = error {
                errorMessage = "Failed to submit: \(error.localizedDescription)"
            } else {
                submissionSuccess = true
                // Clear fields for UX
                parentName = ""
                childName = ""
                teamID = ""
                reason = ""
            }
        }
    }
}
