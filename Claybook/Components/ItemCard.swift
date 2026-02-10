import SwiftUI
import SwiftData

struct ItemCard: View {
    let item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cover photo area
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.theme.surfaceSecondary)
                    .aspectRatio(1, contentMode: .fit)

                if let photo = item.displayPhoto {
                    PhotoThumbnail(fileName: photo.fileName, contentMode: .fit)
                        .padding(8)
                } else {
                    Image(systemName: item.type.icon)
                        .font(.largeTitle)
                        .foregroundStyle(Color.theme.textTertiary)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.theme.textPrimary)
                    .lineLimit(1)

                StageBadge(stage: item.currentStage)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .cardStyle()
        .overlay(alignment: .topTrailing) {
            if item.isFavorite {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
                    .padding(8)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.currentStage.displayName)\(item.isFavorite ? ", favorite" : "")")
    }
}
