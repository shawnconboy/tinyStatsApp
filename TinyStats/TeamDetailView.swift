import SwiftUI
import FirebaseFirestore

struct TeamDetailView: View {
    let team: Team

    @State private var members: [Member] = []
    @State private var selectedMember: Member?
    
    @State private var admins: [Admin] = []
    @State private var selectedAdmin: Admin?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(team.name)
                    .font(.largeTitle.bold())
                    .padding(.horizontal)

                // Admin Section
                Text("Admins")
                    .font(.title2)
                    .padding(.horizontal)

                ForEach(admins) { admin in
                    Button(action: {
                        selectedAdmin = admin
                    }) {
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
                    .buttonStyle(PlainButtonStyle())
                }

                // Member Section
                Text("Members")
                    .font(.title2)
                    .padding(.horizontal)

                ForEach(members) { member in
                    Button(action: {
                        selectedMember = member
                    }) {
                        MemberCardView(member: member)
                            .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top)
        }
        .onAppear {
            fetchMembers()
            fetchAdmins()
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
}
