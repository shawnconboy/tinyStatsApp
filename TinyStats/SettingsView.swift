import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    Button("Log In") {
                        // trigger login sheet
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
