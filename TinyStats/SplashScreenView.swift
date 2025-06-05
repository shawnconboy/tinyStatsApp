import SwiftUI

struct SplashScreenView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            Image("SplashLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 350)
                .scaleEffect(animate ? 1 : 0.85)
                .opacity(animate ? 1 : 0)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.6)) {
                        animate = true
                    }
                }
        }
    }
}
