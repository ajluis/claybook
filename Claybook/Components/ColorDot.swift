import SwiftUI

struct ColorDot: View {
    let hex: String
    var size: CGFloat = 24

    var body: some View {
        Circle()
            .fill(Color(hex: hex))
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(Color.theme.textTertiary.opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview {
    HStack {
        ColorDot(hex: "#C2694F")
        ColorDot(hex: "#8B9D77")
        ColorDot(hex: "#0047AB")
    }
}
