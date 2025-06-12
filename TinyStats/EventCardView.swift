import SwiftUI

struct EventCardView: View {
    let event: Event

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(event.teamAName) vs \(event.teamBName)")
                    .font(.headline)
                Text(event.eventDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let volunteer = event.snackVolunteerName, !volunteer.isEmpty {
                    Text("Snack Volunteer: \(volunteer)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
