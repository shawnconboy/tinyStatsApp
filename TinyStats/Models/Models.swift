import Foundation

struct FavoriteItem: Identifiable {
    let id = UUID()
    let name: String
    let type: String  // "Team" or "Player"
}

struct Game: Identifiable {
    let id = UUID()
    let teamAName: String
    let teamBName: String
    let quarter: Int
    let timeRemaining: String
}

let mockFavorites = [
    FavoriteItem(name: "Sharks", type: "Team"),
    FavoriteItem(name: "Jordan Smith", type: "Player")
]

let mockLiveGames = [
    Game(teamAName: "Sharks", teamBName: "Tigers", quarter: 2, timeRemaining: "05:23"),
    Game(teamAName: "Wolves", teamBName: "Eagles", quarter: 3, timeRemaining: "02:10")
]

// MARK: - Team Schedule

struct TeamScheduleItem: Identifiable {
    let id = UUID()
    let date: Date
    let type: String  // "Game" or "Practice"
    let opponent: String?
    let time: String
    let location: String
    let snackParent: String?
    let eventNote: String?
}

let mockTeamSchedule: [TeamScheduleItem] = [
    TeamScheduleItem(
        date: Date().addingTimeInterval(86400 * 1),
        type: "Game",
        opponent: "Tigers",
        time: "5:00 PM",
        location: "Field A",
        snackParent: "Jamie’s Mom",
        eventNote: nil
    ),
    TeamScheduleItem(
        date: Date().addingTimeInterval(86400 * 3),
        type: "Practice",
        opponent: nil,
        time: "6:30 PM",
        location: "Field B",
        snackParent: nil,
        eventNote: "Picture Day"
    )
]

// MARK: - Admin Panel Models

struct Organization: Identifiable {
    let id: String
    let name: String
}

struct UserRecord: Identifiable {
    let id: String
    let email: String
    let teamID: String
}

struct Team: Identifiable {
    let id: String
    let name: String
    let playerCount: Int
}
