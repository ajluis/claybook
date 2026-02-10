import SwiftUI

struct PhotoThumbnail: View {
    let fileName: String
    var contentMode: ContentMode = .fill

    var body: some View {
        Group {
            if let image = ThumbnailService.shared.loadThumbnail(for: fileName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Color.theme.surfaceSecondary
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(Color.theme.textTertiary)
                    }
            }
        }
    }
}
