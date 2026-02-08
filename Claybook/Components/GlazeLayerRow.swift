import SwiftUI

struct GlazeLayerRow: View {
    let glaze: GlazeEntry
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(Color.theme.textTertiary)
                .largeTapTarget()

            VStack(alignment: .leading, spacing: 2) {
                Text(glaze.name)
                    .font(.body)
                    .foregroundStyle(Color.theme.textPrimary)

                Text("Layer \(glaze.order)")
                    .font(.caption)
                    .foregroundStyle(Color.theme.textSecondary)
            }

            Spacer()

            if let onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.theme.textTertiary)
                }
                .largeTapTarget()
            }
        }
        .padding(.vertical, 4)
    }
}
