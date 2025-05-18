import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            TeamTabView()
                .tabItem {
                    Label("Team", systemImage: "person.3.fill")
                }

            PlayerZoneView()
                .tabItem {
                    Label("Player Zone", systemImage: "graduationcap.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .preferredColorScheme(.light)
    }
}
