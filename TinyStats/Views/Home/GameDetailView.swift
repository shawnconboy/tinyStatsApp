import SwiftUI

struct GameDetailView: View {
    let game: Game

    var body: some View {
        VStack(spacing: 16) {
            Text("\(game.teamAName) vs \(game.teamBName)")
                .font(.largeTitle.bold())

            Text("Quarter: \(game.quarter)")
            Text("Time: \(game.timeRemaining)")

            Spacer()

            NavigationLink("View Scoreboard", destination: LiveGameView(game: GameState()))
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
    }
}
