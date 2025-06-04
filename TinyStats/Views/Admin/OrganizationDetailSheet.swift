import SwiftUI

struct OrganizationDetailSheet: View {
    let org: Organization
    @Binding var showAddAdminModal: Bool
    @Binding var showAddTeamModal: Bool
    @Binding var selectedOrg: Organization?
    let fetchOrganizations: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(org.name)
                    .font(.largeTitle.bold())
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)

                // Admins Section
                OrgAdminsView(orgID: org.id) {
                    selectedOrg = org // ✅ Ensure correct org is passed
                    showAddAdminModal = true
                }
                .padding(.top, 16)
                .padding(.bottom, 16)
                .padding(.horizontal, 20)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(radius: 2, y: 2)

                // Teams Section
                OrgTeamsView(orgID: org.id) {
                    selectedOrg = org // ✅ Ensure correct org is passed
                    showAddTeamModal = true
                }
                .padding(.top, 16)
                .padding(.bottom, 16)
                .padding(.horizontal, 20)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(radius: 2, y: 2)

                // Edit Org Button
                Button {
                    selectedOrg = org
                } label: {
                    Label("Edit Organization", systemImage: "pencil")
                        .font(.body.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .padding(.top, 18)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 24)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
