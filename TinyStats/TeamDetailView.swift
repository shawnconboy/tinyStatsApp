import SwiftUI
import FirebaseFirestore

struct TeamDetailView: View {
    let team: Team

    @State private var members: [Member] = []
    @State private var selectedMember: Member?

    @State private var admins: [Admin] = []
    @State private var selectedAdmin: Admin?

    @State private var pendingRequests: [JoinRequest] = []
    @State private var selectedRequest: JoinRequest?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(team.name)
                    .font(.largeTitle.bold())
                    .padding(.horizontal)

                // Admins
                Text("Admins")
                    .font(.title2)
                    .padding(.horizontal)

                ForEach(admins) { admin in
                    Button {
                        selectedAdmin = admin
                    } label: {
                        HStack {
                            Text(admin.name)
                                .font(.headline)
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    .buttonStyle(.plain)
                }

                // Pending Join Requests
                if !pendingRequests.isEmpty {
                    Text("Pending Join Requests")
                        .font(.title2)
                        .padding(.horizontal)

                    ForEach(pendingRequests) { request in
                        Button {
                            selectedRequest = request
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(request.parentName)
                                        .font(.headline)
                                    Text("Child: \(request.childName)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.orange.opacity(0.15))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Members
                Text("Members")
                    .font(.title2)
                    .padding(.horizontal)

                ForEach(members) { member in
                    Button {
                        selectedMember = member
                    } label: {
                        MemberCardView(member: member)
                            .padding(.horizontal)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top)
        }
        .onAppear {
            fetchAdmins()
            fetchPendingRequests()
            fetchMembers()
        }
        .sheet(item: $selectedMember) { member in
            EditMemberView(member: member) {
                fetchMembers()
            }
        }
        .sheet(item: $selectedAdmin) { admin in
            EditAdminView(admin: admin) {
                fetchAdmins()
            }
        }
        .sheet(item: $selectedRequest) { request in
            ReviewJoinRequestView(
                request: request,
                onApprove: { jerseyNumber in
                    approveRequest(request, jerseyNumber: jerseyNumber)
                    selectedRequest = nil
                },
                onDeny: {
                    denyRequest(request)
                    selectedRequest = nil
                }
            )
        }
    }

    func fetchMembers() {
        let db = Firestore.firestore()
        db.collection("members")
            .whereField("teamID", isEqualTo: team._id)
            .getDocuments { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.members = docs.map { doc in
                    let data = doc.data()
                    return Member(
                        _id: doc.documentID,
                        parentName: data["name"] as? String ?? "",
                        childName: data["childName"] as? String ?? "",
                        jerseyNumber: data["playerNumber"] as? Int ?? 0,
                        teamID: data["teamID"] as? String ?? ""
                    )
                }
            }
    }

    func fetchAdmins() {
        let db = Firestore.firestore()
        db.collection("admins")
            .whereField("organizationID", isEqualTo: team.organizationID)
            .getDocuments { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.admins = docs.map { doc in
                    let data = doc.data()
                    return Admin(
                        _id: doc.documentID,
                        name: data["name"] as? String ?? "",
                        uid: data["uid"] as? String ?? "",
                        email: data["email"] as? String,
                        role: data["role"] as? String
                    )
                }
            }
    }

    func fetchPendingRequests() {
        let db = Firestore.firestore()
        db.collection("joinRequests")
            .whereField("teamID", isEqualTo: team._id)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.pendingRequests = docs.map { doc in
                    let data = doc.data()
                    return JoinRequest(
                        id: doc.documentID,
                        parentName: data["parentName"] as? String ?? "",
                        childName: data["childName"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        teamID: data["teamID"] as? String ?? "",
                        status: data["status"] as? String ?? "",
                        uid: data["uid"] as? String ?? ""
                    )
                }
            }
    }

    func approveRequest(_ request: JoinRequest, jerseyNumber: Int) {
        let db = Firestore.firestore()

        let nameParts = request.parentName.split(separator: " ")
        let firstName = nameParts.first?.lowercased() ?? "parent"
        let lastInitial = nameParts.dropFirst().first?.prefix(1).capitalized ?? "X"
        let formattedName = "\(firstName)\(lastInitial)"

        let orgID = team.organizationID
        let role = "parent"
        let baseID = "\(role)_\(formattedName)_\(orgID)_"

        db.collection("members")
            .whereField("teamID", isEqualTo: team._id)
            .getDocuments { snapshot, _ in
                let similarIDs = snapshot?.documents.map { $0.documentID }
                    .filter { $0.hasPrefix(baseID) } ?? []

                let nextNumber = similarIDs.count + 1
                let formattedNumber = String(format: "%03d", nextNumber)
                let fullID = baseID + formattedNumber

                let newMember: [String: Any] = [
                    "name": request.parentName,
                    "childName": request.childName,
                    "email": request.email,
                    "teamID": request.teamID,
                    "uid": request.uid,
                    "approved": true,
                    "playerNumber": jerseyNumber,
                    "role": role
                ]

                db.collection("members").document(fullID).setData(newMember) { error in
                    if error == nil {
                        db.collection("joinRequests").document(request.id).delete()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            fetchPendingRequests()
                            fetchMembers()
                        }
                    }
                }
            }
    }

    func denyRequest(_ request: JoinRequest) {
        let db = Firestore.firestore()
        db.collection("joinRequests").document(request.id).delete { error in
            if error == nil {
                fetchPendingRequests()
            }
        }
    }
}
