import SwiftUI

struct PhotoStrip: View {
    let photos: [Photo]
    var onPhotoTapped: ((Photo) -> Void)? = nil

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(photos, id: \.id) { photo in
                    PhotoThumbnail(fileName: photo.fileName)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture { onPhotoTapped?(photo) }
                }
            }
            .padding(.horizontal, Constants.Layout.horizontalPadding)
        }
    }
}
