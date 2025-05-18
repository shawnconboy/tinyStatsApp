import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            TeamView()
                .id("team-tab") // Prevents tab bouncing by maintaining stable identity
                .tabItem {
                    Label("Team", systemImage: "person.3")
                }

            PlayerZoneView()
                .tabItem {
                    Label("Player Zone", systemImage: "graduationcap")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
