import SwiftUI
import FirebaseFirestore

struct AdminManagementView: View {
    @State private var organizations: [Organization] = []
    @State private var isLoading = true

    @State private var selectedOrg: Organization? = nil
    @State private var showAddAdminModal = false
    @State private var showAddTeamModal = false
    @State private var showAddOrgModal = false
    @State private var selectedDetailOrg: Organization? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with Add Button
                    HStack {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.accentColor)
                                .font(.system(size: 32))
                            Text("Admin Control Center")
                                .font(.largeTitle.bold())
                        }

                        Spacer()

                        Button(action: {
                            showAddOrgModal = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        }
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
                                Button(action: {
                                    selectedDetailOrg = org
                                }) {
                                    HStack {
                                        Text(org.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right.circle")
                                            .foregroundColor(.accentColor)
                                    }
                                    .padding(.vertical, 18)
                                    .padding(.horizontal, 20)
                                    .background(Color(.systemGray5).opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                                .buttonStyle(PlainButtonStyle())
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

            // Add Admin
            .sheet(isPresented: $showAddAdminModal) {
                AddAdminFormView(org: selectedOrg ?? Organization(id: "placeholder", name: "Unknown Org")) {
                    showAddAdminModal = false
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .padding()
            }

            // Add Team
            .sheet(isPresented: $showAddTeamModal) {
                AddTeamFormView(org: selectedOrg ?? Organization(id: "placeholder", name: "Unknown Org")) {
                    showAddTeamModal = false
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }

            // Edit Org
            .sheet(item: $selectedOrg, onDismiss: { selectedOrg = nil }) { org in
                EditOrgFormView(org: org) {
                    selectedOrg = nil
                    fetchOrganizations()
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }

            // Add Org
            .sheet(isPresented: $showAddOrgModal) {
                AddOrganizationFormView {
                    showAddOrgModal = false
                    fetchOrganizations()
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }

        // Org Detail Sheet
        .sheet(item: $selectedDetailOrg) { org in
            OrganizationDetailSheet(
                org: org,
                showAddAdminModal: $showAddAdminModal,
                showAddTeamModal: $showAddTeamModal,
                selectedOrg: $selectedOrg,
                fetchOrganizations: fetchOrganizations
            )
        }
    }

    func fetchOrganizations() {
        let db = Firestore.firestore()
        db.collection("organizations").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                self.organizations = docs.map { doc in
                    Organization(
                        id: doc.documentID,
                        name: doc["name"] as? String ?? "Unnamed Org",
                        city: doc["city"] as? String,
                        state: doc["state"] as? String
                    )
                }
            }
            isLoading = false
        }
    }
}
