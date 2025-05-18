import SwiftUI
import FirebaseFirestore

struct AdminManagementView: View {
    @State private var organizations: [Organization] = []
    @State private var expandedOrgID: String?
    @State private var isLoading = true

    @State private var selectedOrg: Organization?
    @State private var showAddAdminModal = false
    @State private var showAddTeamModal = false
    @State private var showEditOrgModal = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Admin Control Center")
                        .font(.largeTitle.bold())
                        .padding(.horizontal)

                    if isLoading {
                        ProgressView("Loading organizations...")
                            .padding()
                    } else {
                        ForEach(organizations) { org in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("🏢 \(org.name)")
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: expandedOrgID == org.id ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        expandedOrgID = expandedOrgID == org.id ? nil : org.id
                                    }
                                }

                                if expandedOrgID == org.id {
                                    VStack(alignment: .leading, spacing: 8) {
                                        OrgAdminsView(orgID: org.id) {
                                            print("Tapped Add Admin for \(org.name)")
                                            selectedOrg = org
                                            showAddAdminModal = true
                                        }

                                        OrgTeamsView(orgID: org.id) {
                                            print("Tapped Add Team for \(org.name)")
                                            selectedOrg = org
                                            showAddTeamModal = true
                                        }

                                        Button("✏️ Edit Org") {
                                            print("Tapped Edit Org for \(org.name)")
                                            selectedOrg = org
                                            showEditOrgModal = true
                                        }
                                        .buttonStyle(.bordered)
                                        .padding(.top, 4)
                                    }
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .onAppear(perform: fetchOrganizations)
            .navigationTitle("Manage Admins")
            .sheet(isPresented: $showAddAdminModal) {
                AddAdminFormView(org: selectedOrg ?? Organization(id: "placeholder", name: "Unknown Org")) {
                    showAddAdminModal = false
                }
            }
            .sheet(isPresented: $showAddTeamModal) {
                AddTeamFormView(org: selectedOrg ?? Organization(id: "placeholder", name: "Unknown Org")) {
                    showAddTeamModal = false
                }
            }
            .sheet(isPresented: $showEditOrgModal) {
                EditOrgFormView(org: selectedOrg ?? Organization(id: "placeholder", name: "Unknown Org")) {
                    showEditOrgModal = false
                    fetchOrganizations()
                }
            }
        }
    }

    func fetchOrganizations() {
        let db = Firestore.firestore()
        db.collection("organizations").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                self.organizations = docs.map { doc in
                    Organization(id: doc.documentID, name: doc["name"] as? String ?? "Unnamed Org")
                }
            }
            isLoading = false
        }
    }
}
