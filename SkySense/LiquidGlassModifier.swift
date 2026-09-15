import SwiftUI

struct LiquidGlass: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(
                    LinearGradient(colors: [.white.opacity(0.8), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
            )
            .shadow(color: .white.opacity(0.2), radius: 10)
    }
}

extension View {
    func liquidGlass() -> some View {
        modifier(LiquidGlass())
    }
}
