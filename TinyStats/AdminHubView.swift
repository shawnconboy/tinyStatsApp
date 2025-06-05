import SwiftUI

struct AdminHubView: View {
    var auth: AuthViewModel  // ✅ Accepts auth

    var body: some View {
        AdminPanelView(auth: auth)  // ✅ Passes auth into AdminPanelView
    }
}
