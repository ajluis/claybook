import UIKit

final class ThumbnailService: ObservableObject {
    static let shared = ThumbnailService()

    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let thumbnailsDirectory: URL

    private init() {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        thumbnailsDirectory = documents.appendingPathComponent("Thumbnails", isDirectory: true)
        try? fileManager.createDirectory(at: thumbnailsDirectory, withIntermediateDirectories: true)

        cache.countLimit = 100
    }

    // MARK: - Load Thumbnail

    func loadThumbnail(for fileName: String) -> UIImage? {
        let cacheKey = NSString(string: fileName)

        // Check memory cache first
        if let cached = cache.object(forKey: cacheKey) {
            return cached
        }

        // Check disk
        let thumbnailURL = thumbnailsDirectory.appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: thumbnailURL),
           let image = UIImage(data: data) {
            cache.setObject(image, forKey: cacheKey)
            return image
        }

        // Generate from original if thumbnail doesn't exist
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let originalURL = documents.appendingPathComponent("Photos").appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: originalURL),
           let original = UIImage(data: data) {
            let thumbnail = original.thumbnailed()
            saveThumbnailToDisk(thumbnail, fileName: fileName)
            cache.setObject(thumbnail, forKey: cacheKey)
            return thumbnail
        }

        return nil
    }

    // MARK: - Generate

    func generateThumbnail(for fileName: String, from image: UIImage) {
        let thumbnail = image.thumbnailed()
        saveThumbnailToDisk(thumbnail, fileName: fileName)
        cache.setObject(thumbnail, forKey: NSString(string: fileName))
    }

    // MARK: - Remove

    func removeCached(fileName: String) {
        cache.removeObject(forKey: NSString(string: fileName))
    }

    func clearCache() {
        cache.removeAllObjects()
    }

    // MARK: - Private

    private func saveThumbnailToDisk(_ image: UIImage, fileName: String) {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return }
        let url = thumbnailsDirectory.appendingPathComponent(fileName)
        try? data.write(to: url)
    }
}
