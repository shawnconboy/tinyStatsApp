import Foundation

// MARK: - Favorites

struct FavoriteItem: Identifiable {
    let id = UUID()
    let name: String
    let type: String  // "Team" or "Player"
}

let mockFavorites = [
    FavoriteItem(name: "Sharks", type: "Team"),
    FavoriteItem(name: "Jordan Smith", type: "Player")
]

// MARK: - Live Games

struct Game: Identifiable {
    let id = UUID()
    let teamAName: String
    let teamBName: String
    let quarter: Int
    let timeRemaining: String
}

let mockLiveGames = [
    Game(teamAName: "Sharks", teamBName: "Tigers", quarter: 2, timeRemaining: "05:23"),
    Game(teamAName: "Wolves", teamBName: "Eagles", quarter: 3, timeRemaining: "02:10")
]

// ❌ Removed the old TeamScheduleItem definition and mockTeamSchedule

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
