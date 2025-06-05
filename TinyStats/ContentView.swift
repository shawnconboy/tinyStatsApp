import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var showSplash = true
    @State private var splashMinimumTimeReached = false

    var body: some View {
        ZStack {
            if auth.isProfileLoaded {
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }

                    TeamsView()
                        .tabItem {
                            Label("Teams", systemImage: "person.3.fill")
                        }

                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }

                    if let role = auth.adminProfile?.role,
                       role == "admin" || role == "developer" {
                        AdminHubView(auth: auth) // ✅ FIXED: Passing required auth param
                            .tabItem {
                                Label("Admin", systemImage: "person.crop.rectangle.stack")
                            }
                    }
                }
            }

            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            // Enforce a minimum 2-second splash display
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                splashMinimumTimeReached = true
                checkIfShouldDismissSplash()
            }
        }
        .onChange(of: auth.isProfileLoaded) { _ in
            checkIfShouldDismissSplash()
        }
    }

    private func checkIfShouldDismissSplash() {
        if auth.isProfileLoaded && splashMinimumTimeReached {
            withAnimation(.easeOut(duration: 0.4)) {
                showSplash = false
            }
        }
    }
}
