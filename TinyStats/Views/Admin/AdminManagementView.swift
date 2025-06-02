import SwiftUI
import FirebaseFirestore

struct AdminManagementView: View {
    @State private var organizations: [Organization] = []
    @State private var expandedOrgID: String?
    @State private var isLoading = true

    @State private var selectedOrg: Organization? = nil
    @State private var showAddAdminModal = false
    @State private var showAddTeamModal = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 32))
                        Text("Admin Control Center")
                            .font(.largeTitle.bold())
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    if isLoading {
                        ProgressView("Loading organizations...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                            .padding(.vertical, 40)
                    
                    } else {
                        if organizations.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "building.2.crop.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 64, height: 64)
                                    .foregroundColor(.gray.opacity(0.3))
                                Text("No organizations found.")
                                    .foregroundColor(.secondary)
                                    .font(.title3)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else {
                            ForEach(organizations) { org in
                                VStack(alignment: .leading, spacing: 0) {
                                    Button(action: {
                                        withAnimation(.spring()) {
                                            expandedOrgID = expandedOrgID == org.id ? nil : org.id
                                        }
                                    }) {
                                        HStack {
                                            Text(org.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: expandedOrgID == org.id ? "chevron.up.circle.fill" : "chevron.down.circle")
                                                .foregroundColor(.accentColor)
                                                .rotationEffect(.degrees(expandedOrgID == org.id ? 180 : 0))
                                                .animation(.easeInOut, value: expandedOrgID == org.id)
                                        }
                                        .padding(.vertical, 18)
                                        .padding(.horizontal, 20)
                                        .background(Color(.systemGray5).opacity(0.5))
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    if expandedOrgID == org.id {
                                        VStack(alignment: .leading, spacing: 16) {
                                            OrgAdminsView(orgID: org.id) {
                                                selectedOrg = org
                                                showAddAdminModal = true
                                            }
                                            .padding(.top, 8)
                                            .padding(.bottom, 12)
                                            .padding(.horizontal, 8)
                                            .background(Color(.systemBackground))
                                            .cornerRadius(12)
                                            .shadow(radius: 1, y: 1)

                                            OrgTeamsView(orgID: org.id) {
                                                selectedOrg = org
                                                showAddTeamModal = true
                                            }
                                            .padding(.top, 4)
                                            .padding(.bottom, 12)
                                            .padding(.horizontal, 8)

                                            Button {
                                                selectedOrg = org
                                            } label: {
                                                Label("Edit Organization", systemImage: "pencil")
                                                    .font(.body.bold())
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .tint(.accentColor)
                                            .padding(.top, 10)
                                            .padding(.horizontal, 8)
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.bottom, 12)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                    }
                                }
                                .background(Color(.systemGray6))
                                .cornerRadius(18)
                                .shadow(color: Color(.black).opacity(0.07), radius: 4, x: 0, y: 2)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 0)
            }
            .onAppear(perform: fetchOrganizations)
            .navigationTitle("Manage Admins")
            .sheet(isPresented: $showAddAdminModal) {
                AddAdminFormView(org: selectedOrg ?? Organization(id: "placeholder", name: "Unknown Org")) {
                    showAddAdminModal = false
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showAddTeamModal) {
                AddTeamFormView(org: selectedOrg ?? Organization(id: "placeholder", name: "Unknown Org")) {
                    showAddTeamModal = false
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(item: $selectedOrg, onDismiss: { selectedOrg = nil }) { org in
                EditOrgFormView(org: org) {
                    selectedOrg = nil
                    fetchOrganizations()
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
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

struct Organization: Identifiable {
    var id: String
    var name: String
}
