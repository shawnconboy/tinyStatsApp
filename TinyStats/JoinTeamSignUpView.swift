import SwiftUI
import Firebase
import FirebaseFirestore

struct JoinTeamSignUpView: View {
    @Environment(\.dismiss) var dismiss

    // Form fields
    @State private var parentName = ""
    @State private var childName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedTeam: Team?

    // Teams fetched from Firestore
    @State private var availableTeams: [Team] = []

    // UI state
    @State private var errorMessage = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            VStack {
                if showSuccess {
                    VStack(spacing: 16) {
                        Text("🎉 Request Submitted!")
                            .font(.title.bold())
                        Text("You’ll gain access once your request is approved.")
                            .multilineTextAlignment(.center)
                        Button("Done") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    Form {
                        Section(header: Text("Parent Info")) {
                            TextField("Parent Name", text: $parentName)
                                .autocapitalization(.words)
                        }

                        Section(header: Text("Child Info")) {
                            TextField("Child Name", text: $childName)
                                .autocapitalization(.words)
                        }

                        Section(header: Text("Login Credentials")) {
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            SecureField("Password", text: $password)
                            SecureField("Confirm Password", text: $confirmPassword)
                        }

                        Section(header: Text("Team")) {
                            Picker("Select Team", selection: $selectedTeam) {
                                ForEach(availableTeams, id: \.self) { team in
                                    Text(team.name).tag(team as Team?)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }

                        Button(isSubmitting ? "Submitting..." : "Submit") {
                            submit()
                        }
                        .disabled(isSubmitting)
                    }
                    .navigationTitle("Join a Team")
                    .onAppear {
                        loadTeams()
                    }
                }
            }
        }
    }

    func loadTeams() {
        let db = Firestore.firestore()
        db.collection("teams").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            self.availableTeams = docs.map { doc in
                let data = doc.data()
                return Team(
                    _id: doc.documentID,
                    name: data["name"] as? String ?? "Unknown",
                    ageGroup: data["ageGroup"] as? String ?? "",
                    organizationID: data["organizationID"] as? String ?? ""
                )
            }

            if self.selectedTeam == nil, let first = self.availableTeams.first {
                self.selectedTeam = first
            }
        }
    }

    func submit() {
        errorMessage = ""
        guard !parentName.isEmpty,
              !childName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password == confirmPassword,
              let selectedTeam = selectedTeam else {
            errorMessage = "Please complete all fields and ensure passwords match."
            return
        }

        isSubmitting = true

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isSubmitting = false
                return
            }

            guard let uid = result?.user.uid else {
                self.errorMessage = "Failed to create account."
                self.isSubmitting = false
                return
            }

            let db = Firestore.firestore()
            db.collection("joinRequests").document(uid).setData([
                "parentName": parentName,
                "childName": childName,
                "email": email,
                "teamID": selectedTeam._id,
                "uid": uid,
                "organizationID": selectedTeam.organizationID,
                "status": "pending",
                "timestamp": FieldValue.serverTimestamp()
            ]) { err in
                self.isSubmitting = false
                if let err = err {
                    self.errorMessage = err.localizedDescription
                } else {
                    self.showSuccess = true
                }
            }
        }
    }
}
