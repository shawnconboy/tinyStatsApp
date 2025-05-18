import SwiftUI

struct PlayerZoneView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Player Zone")
                .font(.largeTitle.bold())
                .padding(.top)

            Text("Coaches can assign videos, reading, and drills here.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}
