import SwiftUI

struct LiveGameView: View {
    @ObservedObject var game: GameState

    var body: some View {
        VStack(spacing: 24) {
            Text("\(game.sport.capitalized) Game")
                .font(.title2.bold())
                .padding(.top)

            // SCORE DISPLAY
            HStack(spacing: 40) {
                VStack {
                    Text(game.teamAName)
                        .font(.headline)
                    Text("\(game.teamAScore)")
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                }

                VStack {
                    Text(game.teamBName)
                        .font(.headline)
                    Text("\(game.teamBScore)")
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.red)
                }
            }

            // QUARTER AND TIME
            VStack(spacing: 10) {
                Text("Quarter: \(game.quarter)")
                    .font(.title3)

                Text("Time Remaining: \(game.timeRemaining)")
                    .font(.system(size: 24, weight: .semibold, design: .monospaced))
            }

            // NOTE
            if !game.note.isEmpty {
                Text("📝 \(game.note)")
                    .italic()
                    .padding(.top)
            }

            Spacer()
        }
        .padding()
    }
}
