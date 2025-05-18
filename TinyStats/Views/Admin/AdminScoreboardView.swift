import SwiftUI

struct AdminScoreboardView: View {
    @ObservedObject var game: GameState

    var body: some View {
        VStack(spacing: 20) {
            Text("Admin Scoreboard").font(.title.bold())

            // SPORT PICKER
            Picker("Sport", selection: $game.sport) {
                Text("Basketball").tag("basketball")
                Text("Football").tag("football")
                Text("Soccer").tag("soccer")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // SCORE DISPLAY + CONTROLS
            HStack {
                VStack(spacing: 10) {
                    Text(game.teamAName).font(.headline)
                    Text("\(game.teamAScore)")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                    ForEach(scoreOptions(for: game.sport), id: \.self) { points in
                        Button("+\(points)") { game.teamAScore += points }
                            .buttonStyle(.borderedProminent)
                    }
                }

                Spacer()

                VStack(spacing: 10) {
                    Text(game.teamBName).font(.headline)
                    Text("\(game.teamBScore)")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                    ForEach(scoreOptions(for: game.sport), id: \.self) { points in
                        Button("+\(points)") { game.teamBScore += points }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(.horizontal)

            // QUARTER CONTROL
            HStack {
                Button("-") { game.quarter = max(1, game.quarter - 1) }
                Text("Quarter: \(game.quarter)").font(.headline)
                Button("+") { game.quarter += 1 }
            }

            // CLOCK DISPLAY + CONTROLS
            VStack {
                Text("Time Left: \(game.timeRemaining)")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))

                HStack {
                    Button(game.isClockRunning ? "Pause" : "Start") {
                        game.isClockRunning ? game.pauseClock() : game.startClock()
                    }
                    .padding()
                    .background(game.isClockRunning ? Color.orange : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    Button("Reset") {
                        game.resetClock()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }

            // NOTE FIELD
            TextField("Note (e.g., Timeout)", text: $game.note)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            NavigationLink("View Live Game", destination: LiveGameView(game: game))
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

            Spacer()
        }
        .padding()
    }

    func scoreOptions(for sport: String) -> [Int] {
        switch sport {
        case "basketball": return [1, 2, 3]
        case "football": return [1, 2, 3, 6]
        case "soccer": return [1]
        default: return [1]
        }
    }
}
