import SwiftUI

struct ShareCardView: View {
    let item: Item
    @Environment(\.dismiss) private var dismiss
    @State private var shareImage: UIImage?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    shareCardContent
                        .padding()
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.1), radius: 8)
                        .padding()

                    if let shareImage {
                        ShareLink(item: Image(uiImage: shareImage), preview: SharePreview(item.title, image: Image(uiImage: shareImage))) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .largeButtonStyle()
                        }
                        .padding(.horizontal, Constants.Layout.horizontalPadding)
                    }
                }
            }
            .background(Color.theme.background)
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear { renderCard() }
        }
    }

    private var shareCardContent: some View {
        VStack(spacing: 16) {
            // Photo
            if let photo = item.displayPhoto {
                PhotoThumbnail(fileName: photo.fileName)
                    .aspectRatio(4/3, contentMode: .fill)
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Title + type
            VStack(spacing: 4) {
                Text(item.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.theme.textPrimary)
                Text(item.type.displayName)
                    .font(.subheadline)
                    .foregroundStyle(Color.theme.textSecondary)
            }

            // Clay
            if let clay = item.clayType, !clay.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "circle.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.theme.accent)
                    Text(clay)
                        .font(.subheadline)
                        .foregroundStyle(Color.theme.textSecondary)
                }
            }

            // Glazes
            let glazes = item.stageLogs.flatMap(\.glazesUsed).sorted { $0.order < $1.order }
            if !glazes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Glazes")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.theme.textSecondary)
                    ForEach(glazes, id: \.id) { glaze in
                        Text("\(glaze.order). \(glaze.name)")
                            .font(.subheadline)
                            .foregroundStyle(Color.theme.textPrimary)
                    }
                }
            }

            // Colors
            let colors = item.stageLogs.flatMap(\.colorsUsed)
            if !colors.isEmpty {
                HStack(spacing: 6) {
                    ForEach(colors, id: \.id) { color in
                        if let hex = color.paletteColor {
                            ColorDot(hex: hex, size: 20)
                        }
                    }
                }
            }

            // Outcome notes
            if let finishedLog = item.stageLogs.first(where: { $0.stage == .finished }),
               let notes = finishedLog.notes, !notes.isEmpty {
                Text(notes)
                    .font(.body)
                    .foregroundStyle(Color.theme.textSecondary)
                    .italic()
            }

            // Watermark
            Text("Made with Claybook")
                .font(.caption2)
                .foregroundStyle(Color.theme.textTertiary)
                .padding(.top, 4)
        }
    }

    @MainActor
    private func renderCard() {
        shareImage = ShareCardRenderer.render(view: shareCardContent)
    }
}
