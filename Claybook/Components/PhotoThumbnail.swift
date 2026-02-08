import SwiftUI

struct PhotoThumbnail: View {
    let fileName: String

    var body: some View {
        Group {
            if let image = ThumbnailService.shared.loadThumbnail(for: fileName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
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
