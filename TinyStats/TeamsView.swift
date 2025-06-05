import SwiftUI

struct TeamsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("See Schedule and Messages")
                    .font(.title.bold())
                Spacer()
            }
            .padding()
            .navigationTitle("Team Hub")
        }
    }
}
