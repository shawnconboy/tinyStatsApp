import SwiftUI

struct TeamScheduleTile: View {
    let item: TeamScheduleItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.date.formatted(.dateTime.month().day().weekday()))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(item.time)
                    .font(.subheadline)
            }

            Text(item.type + (item.opponent != nil ? " vs \(item.opponent!)" : ""))
                .font(.headline)

            Text(item.location)
                .font(.caption)
                .foregroundColor(.secondary)

            if let snack = item.snackParent {
                Text("🧁 Snack: \(snack)")
                    .font(.caption)
            }

            if let note = item.eventNote {
                Text("📸 \(note)")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
