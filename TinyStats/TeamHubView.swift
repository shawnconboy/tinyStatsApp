import SwiftUI

struct TeamHubView: View {
    let team: Team

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome to the Team Hub")
                .font(.largeTitle.bold())

            Text("Here you'll find your team schedule, chat, and updates.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            NavigationLink(destination: TeamChatView(teamID: team.id)) {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.title2)
                    Text("Team Chat")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Team Hub")
        .navigationBarTitleDisplayMode(.inline)
    }
}
