import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 1.0

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            Image("SplashLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .opacity(opacity)
        }
        .onAppear {
            // Wait 0.8s before starting fade
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeOut(duration: 1.6)) {
                    opacity = 0.0
                }
            }

            // Transition after 2.5s
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                isActive = true
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            MainTabView()
        }
        .preferredColorScheme(.light)
    }
}
