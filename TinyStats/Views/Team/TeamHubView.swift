import SwiftUI

struct TeamHubView: View {
    let teamID: String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Main Header
                    Text("Team Hub")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)

                    // Team Info
                    VStack(spacing: 4) {
                        Text("Sharks") // To be dynamic later
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("12U Coed Team")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)

                    // Chat Button
                    NavigationLink(destination: TeamChatView(teamID: teamID)) {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                            Text("Open Team Chat")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Upcoming Schedule
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming")
                            .font(.title2.bold())
                            .padding(.horizontal)

                        ForEach(mockTeamSchedule) { item in
                            TeamScheduleTile(item: item)
                                .padding(.horizontal)
                        }
                    }

                    Spacer()
                }
                .padding(.bottom)
            }
        }
    }
}
