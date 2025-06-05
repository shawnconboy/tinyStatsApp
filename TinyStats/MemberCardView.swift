import SwiftUI

struct MemberCardView: View {
    var member: Member

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(member.parentName)
                    .font(.headline)

                Text(member.childName.isEmpty ? "Unknown" : member.childName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if member.jerseyNumber != 0 {
                Text("#\(member.jerseyNumber)")
                    .font(.title3.bold())
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
