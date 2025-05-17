import SwiftUI

struct LiveGameCard: View {
    let game: Game

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(game.teamAName)")
                .font(.subheadline.bold())
            Text("vs")
                .font(.caption)
                .foregroundColor(.gray)
            Text("\(game.teamBName)")
                .font(.subheadline.bold())
            Text("Q\(game.quarter) • \(game.timeRemaining)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .frame(width: 110, height: 110)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
