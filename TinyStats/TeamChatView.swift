import SwiftUI

struct TeamChatView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Team Chat")
                .font(.largeTitle.bold())
                .padding(.top)

            Text("Group chat between coaches, parents, and players.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}
