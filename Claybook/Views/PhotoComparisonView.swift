import SwiftUI

struct PhotoComparisonView: View {
    let item: Item
    @Environment(\.dismiss) private var dismiss
    @State private var mode: ComparisonMode = .swipe
    @State private var currentIndex = 0
    @State private var topStageIndex = 0
    @State private var bottomStageIndex = 1

    enum ComparisonMode {
        case swipe, sideBySide
    }

    private var stagePhotos: [(stage: StageType, photo: Photo)] {
        item.stageLogs
            .sorted { $0.stage.rawValue < $1.stage.rawValue }
            .flatMap { log in
                log.photos.map { (stage: log.stage, photo: $0) }
            }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if stagePhotos.isEmpty {
                    Text("No photos to compare")
                        .foregroundStyle(.white)
                } else if mode == .swipe {
                    swipeMode
                } else {
                    sideBySideMode
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                            .largeTapTarget()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        mode = mode == .swipe ? .sideBySide : .swipe
                    } label: {
                        Image(systemName: mode == .swipe ? "rectangle.split.1x2" : "hand.draw")
                            .foregroundStyle(.white)
                            .largeTapTarget()
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private var swipeMode: some View {
        TabView(selection: $currentIndex) {
            ForEach(stagePhotos.indices, id: \.self) { index in
                let item = stagePhotos[index]
                ZStack(alignment: .bottom) {
                    if let image = PhotoStorageService.shared.loadOriginal(fileName: item.photo.fileName) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        PhotoThumbnail(fileName: item.photo.fileName)
                    }

                    VStack(spacing: 4) {
                        Text(item.stage.displayName)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(item.photo.capturedAt.mediumDisplay)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.bottom, 40)
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }

    private var sideBySideMode: some View {
        VStack(spacing: 2) {
            if !stagePhotos.isEmpty {
                comparisonSlot(index: $topStageIndex)
                comparisonSlot(index: $bottomStageIndex)
            }
        }
    }

    private func comparisonSlot(index: Binding<Int>) -> some View {
        let safeIndex = min(index.wrappedValue, stagePhotos.count - 1)
        let item = stagePhotos[max(0, safeIndex)]
        return VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                if let image = PhotoStorageService.shared.loadOriginal(fileName: item.photo.fileName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                } else {
                    PhotoThumbnail(fileName: item.photo.fileName)
                        .frame(maxWidth: .infinity)
                }

                Menu {
                    ForEach(stagePhotos.indices, id: \.self) { i in
                        Button(stagePhotos[i].stage.displayName) {
                            index.wrappedValue = i
                        }
                    }
                } label: {
                    Text(item.stage.shortName)
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.black.opacity(0.6))
                        .clipShape(Capsule())
                        .padding(12)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}
