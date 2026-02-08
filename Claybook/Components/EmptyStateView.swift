import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(Color.theme.accent.opacity(0.6))

            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.theme.textPrimary)

                Text(message)
                    .font(.body)
                    .foregroundStyle(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if let buttonTitle, let action {
                LargeButton(title: buttonTitle, icon: "plus", action: action)
                    .padding(.horizontal, 48)
                    .padding(.top, 8)
            }

            Spacer()
        }
    }
}

#Preview {
    EmptyStateView(
        icon: "cup.and.saucer",
        title: "No Pieces Yet",
        message: "Start tracking your pottery by adding your first piece.",
        buttonTitle: "Add Your First Piece",
        action: {}
    )
}
