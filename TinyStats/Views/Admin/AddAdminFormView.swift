import SwiftUI
import FirebaseFirestore

struct AddAdminFormView: View {
    let org: Organization
    var onComplete: () -> Void

    @State private var email = ""
    @State private var teamID = ""

    @State private var isSubmitting = false
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 18) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 54, height: 54)
                        .foregroundColor(.accentColor)
                        .padding(.top, 8)

                    Text("Add a new admin to \(org.name)")
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 10)
                }
                .padding(.top, 16)
                .padding(.bottom, 6)

                VStack(spacing: 18) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .autocapitalization(.none)

                    TextField("Team ID", text: $teamID)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .autocapitalization(.none)
                }
                .padding(.horizontal, 12)

                if isSubmitting {
                    ProgressView("Adding admin...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .padding(.top, 8)
                } else if showSuccess {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Admin added!")
                            .foregroundColor(.green)
                    }
                    .font(.headline)
                }

                Button {
                    isSubmitting = true

                    let db = Firestore.firestore()
                    let newAdmin: [String: Any] = [
                        "email": email,
                        "displayName": "",
                        "role": "admin",
                        "status": "approved",
                        "isApproved": true,
                        "orgID": org.id,  // ✅ FIXED: no more placeholder
                        "teamID": teamID,
                        "createdAt": Timestamp()
                    ]

                    db.collection("users").addDocument(data: newAdmin) { error in
                        isSubmitting = false

                        if let error = error {
                            print("❌ Failed to add admin: \(error.localizedDescription)")
                            return
                        }

                        showSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                            showSuccess = false
                            onComplete()
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Admin")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(email.isEmpty || teamID.isEmpty ? Color(.systemGray4) : Color.accentColor)
                    .foregroundColor((email.isEmpty || teamID.isEmpty) ? .gray : .white)
                    .cornerRadius(12)
                }
                .disabled(email.isEmpty || teamID.isEmpty || isSubmitting)
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Add Admin")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        onComplete()
                    }
                }
            }
        }
    }
}
