import SwiftUI

struct TeamHubView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to the Team Hub")
                .font(.largeTitle.bold())

            Text("Here you'll find your team schedule, chat, and updates.")
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .navigationTitle("Team Hub")
    }
}
