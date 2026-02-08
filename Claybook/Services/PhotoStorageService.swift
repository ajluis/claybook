import UIKit

final class PhotoStorageService {
    static let shared = PhotoStorageService()

    private let fileManager = FileManager.default
    private let photosDirectory: URL
    private let thumbnailsDirectory: URL

    private init() {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        photosDirectory = documents.appendingPathComponent("Photos", isDirectory: true)
        thumbnailsDirectory = documents.appendingPathComponent("Thumbnails", isDirectory: true)

        try? fileManager.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: thumbnailsDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Save

    /// Saves an image to disk, resized to max 2048px, returns the filename
    func savePhoto(_ image: UIImage) -> String? {
        let resized = image.resized(maxDimension: 2048)
        guard let data = resized.jpegData(compressionQuality: 0.85) else { return nil }

        let fileName = UUID().uuidString + ".jpg"
        let fileURL = photosDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            // Also generate thumbnail immediately
            ThumbnailService.shared.generateThumbnail(for: fileName, from: resized)
            return fileName
        } catch {
            print("Failed to save photo: \(error)")
            return nil
        }
    }

    // MARK: - Load

    func loadOriginal(fileName: String) -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }

    func originalURL(for fileName: String) -> URL {
        photosDirectory.appendingPathComponent(fileName)
    }

    // MARK: - Delete

    func deletePhoto(fileName: String) {
        let originalURL = photosDirectory.appendingPathComponent(fileName)
        let thumbnailURL = thumbnailsDirectory.appendingPathComponent(fileName)

        try? fileManager.removeItem(at: originalURL)
        try? fileManager.removeItem(at: thumbnailURL)
        ThumbnailService.shared.removeCached(fileName: fileName)
    }

    // MARK: - Helpers

    func photoExists(fileName: String) -> Bool {
        fileManager.fileExists(atPath: photosDirectory.appendingPathComponent(fileName).path)
    }
}
