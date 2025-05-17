import SwiftUI

struct FavoriteCard: View {
    let favorite: FavoriteItem

    var body: some View {
        VStack(spacing: 8) {
            Text(favorite.name)
                .font(.headline)
            Text(favorite.type)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 120, height: 80)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
