import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Live Games & Favorites")
                    .font(.title.bold())
                Spacer()
            }
            .padding()
            .navigationTitle("Tiny Stats")
        }
    }
}
