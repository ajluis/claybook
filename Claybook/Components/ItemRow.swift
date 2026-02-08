import SwiftUI
import SwiftData

struct ItemRow: View {
    let item: Item

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.theme.surfaceSecondary)
                    .frame(width: 60, height: 60)

                if let photo = item.displayPhoto {
                    PhotoThumbnail(fileName: photo.fileName)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: item.type.icon)
                        .foregroundStyle(Color.theme.textTertiary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.theme.textPrimary)

                HStack(spacing: 8) {
                    StageBadge(stage: item.currentStage)

                    if let clay = item.clayType, !clay.isEmpty {
                        Text(clay)
                            .font(.caption)
                            .foregroundStyle(Color.theme.textSecondary)
                    }
                }
            }

            Spacer()

            if item.isFavorite {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
}
