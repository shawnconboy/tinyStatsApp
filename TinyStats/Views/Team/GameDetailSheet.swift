import SwiftUI

struct GameDetailSheet: View {
    let item: TeamScheduleItem

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Game Details")
                .font(.largeTitle.bold())

            Text("Opponent: \(item.opponent ?? "Unknown")")
                .font(.title2)

            Text("Location: \(item.location ?? "TBD")")
                .font(.body)

            Text("Date: \(item.date.formatted(.dateTime.month().day().hour().minute()))")
                .font(.body)

            Text("Notes:")
                .font(.headline)

            Text(item.notes ?? "No additional info")
                .font(.body)

            Spacer()
        }
        .padding()
    }
}
