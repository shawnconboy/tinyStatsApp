import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct AdminDashboardView: View {
    let userRole: String

    @State private var requests: [JoinRequest] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            List {
                ForEach(requests) { request in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(request.parentName).font(.headline)
                            Spacer()
                            Text(request.teamID.uppercased()).font(.caption).foregroundColor(.gray)
                        }

                        Text("Child: \(request.childName)").font(.subheadline)
                        Text("Reason: \(request.reason)").font(.footnote).foregroundColor(.secondary)

                        HStack {
                            Button("Approve") {
                                approve(request)
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Reject") {
                                reject(request)
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Pending Requests")
            .onAppear {
                fetchRequests()
            }
        }
    }

    func fetchRequests() {
        let db = Firestore.firestore()
        var query = db.collection("joinRequests").whereField("status", isEqualTo: "pending")

        // If not developer, only fetch matching team
        if userRole == "admin", let currentUser = Auth.auth().currentUser {
            db.collection("users").document(currentUser.uid).getDocument { doc, error in
                if let doc = doc, let teamID = doc.data()?["teamID"] as? String {
                    query = query.whereField("teamID", isEqualTo: teamID.lowercased())
                }
                runQuery(query)
            }
        } else {
            runQuery(query)
        }
    }

    func runQuery(_ query: Query) {
        query.getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                self.requests = docs.compactMap { doc -> JoinRequest? in
                    let data = doc.data()
                    return JoinRequest(id: doc.documentID, data: data)
                }
            }
            self.isLoading = false
        }
    }

    func approve(_ request: JoinRequest) {
        let db = Firestore.firestore()
        let uid = request.uid

        // Update user record (or create if it doesn’t exist)
        let userRef = db.collection("users").document(uid)
        userRef.setData([
            "email": request.email,
            "status": "approved",
            "role": "parent",
            "teamID": request.teamID
        ], merge: true)

        // Mark request as approved
        db.collection("joinRequests").document(request.id).updateData([
            "status": "approved"
        ])

        // Refresh list
        self.requests.removeAll { $0.id == request.id }
    }

    func reject(_ request: JoinRequest) {
        let db = Firestore.firestore()
        db.collection("joinRequests").document(request.id).delete()
        self.requests.removeAll { $0.id == request.id }
    }
}
