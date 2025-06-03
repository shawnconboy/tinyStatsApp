import SwiftUI

struct TeamDetailSheet: View {
    let team: Team
    // You can add more bindings here if you want to show members, schedule, etc.

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(team.name)
                    .font(.largeTitle.bold())
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                HStack {
                    Text("Age Group: \(team.ageGroup)")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal, 20)
                Divider().padding(.horizontal, 20)
                TeamMembersManager(team: team)
                    .padding(.horizontal, 8)
                Divider().padding(.horizontal, 20)
                TeamScheduleManager(team: team)
                    .padding(.horizontal, 8)
                Spacer(minLength: 30)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
