import SwiftUI

struct TeamHubView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Team Header
                    VStack(spacing: 4) {
                        Text("Sharks")
                            .font(.largeTitle.bold())
                        Text("12U Coed Team")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)

                    // Chat Button
                    NavigationLink(destination: TeamChatView()) {
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

                    // Master Schedule
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
            .navigationTitle("Team")
        }
    }
}
