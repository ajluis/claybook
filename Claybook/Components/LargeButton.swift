import SwiftUI

struct LargeButton: View {
    let title: String
    var icon: String? = nil
    var style: ButtonStyle = .primary
    let action: () -> Void

    enum ButtonStyle {
        case primary, secondary, destructive

        var backgroundColor: Color {
            switch self {
            case .primary: .theme.primary
            case .secondary: .theme.surfaceSecondary
            case .destructive: .theme.destructive
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary: .white
            case .secondary: .theme.textPrimary
            case .destructive: .white
            }
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .largeButtonStyle(
                backgroundColor: style.backgroundColor,
                foregroundColor: style.foregroundColor
            )
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        LargeButton(title: "Save", icon: "checkmark", action: {})
        LargeButton(title: "Add Details", style: .secondary, action: {})
        LargeButton(title: "Delete", icon: "trash", style: .destructive, action: {})
    }
    .padding()
}
