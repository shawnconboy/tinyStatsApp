import SwiftUI

struct HomeView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // FAVORITES SECTION
                    if !mockFavorites.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Favorites")
                                .font(.title2.bold())
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(mockFavorites) { favorite in
                                        FavoriteCard(favorite: favorite)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // LIVE GAMES SECTION
                    if !mockLiveGames.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Live Games")
                                .font(.title2.bold())
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(mockLiveGames) { game in
                                        NavigationLink(destination: GameDetailView(game: game)) {
                                            LiveGameCard(game: game)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                }
                .padding(.top)
            }
            .navigationTitle("Tiny Stats")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Search action to be implemented
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
        }
    }
}
