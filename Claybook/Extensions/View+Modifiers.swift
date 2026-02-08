import SwiftUI

// MARK: - Card Style
struct CardStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Large Button Style
struct LargeButtonStyleModifier: ViewModifier {
    let backgroundColor: Color
    let foregroundColor: Color

    func body(content: Content) -> some View {
        content
            .font(.body.weight(.semibold))
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Large Tap Target
struct LargeTapTargetModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
    }
}

// MARK: - Section Header Style
struct SectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.theme.textSecondary)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyleModifier())
    }

    func largeButtonStyle(
        backgroundColor: Color = .theme.primary,
        foregroundColor: Color = .white
    ) -> some View {
        modifier(LargeButtonStyleModifier(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor
        ))
    }

    func largeTapTarget() -> some View {
        modifier(LargeTapTargetModifier())
    }

    func sectionHeader() -> some View {
        modifier(SectionHeaderModifier())
    }
}
