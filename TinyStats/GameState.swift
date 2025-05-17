import Foundation
import Combine

class GameState: ObservableObject {
    @Published var sport = "basketball"
    @Published var teamAName = "Team A"
    @Published var teamBName = "Team B"
    @Published var teamAScore = 0
    @Published var teamBScore = 0
    @Published var quarter = 1
    @Published var timeRemaining = "08:00"
    @Published var isClockRunning = false
    @Published var note = ""

    private var secondsRemaining = 8 * 60
    private var timer: Timer?

    func startClock() {
        guard timer == nil else { return }
        isClockRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.secondsRemaining > 0 {
                self.secondsRemaining -= 1
                self.updateTime()
            } else {
                self.stopClock()
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    func pauseClock() {
        timer?.invalidate()
        timer = nil
        isClockRunning = false
    }

    func resetClock(to seconds: Int = 8 * 60) {
        pauseClock()
        secondsRemaining = seconds
        updateTime()
    }

    private func updateTime() {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        timeRemaining = String(format: "%02d:%02d", minutes, seconds)
    }

    private func stopClock() {
        pauseClock()
    }
}
