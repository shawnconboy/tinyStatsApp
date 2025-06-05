import SwiftUI
import Firebase

@main
struct TinyStatsApp: App {
    @StateObject var authViewModel = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environment(\.colorScheme, .light) // 👈 Forces light mode
        }
    }
}
