import SwiftUI
import UIKit

final class ShareService {
    static let shared = ShareService()
    private init() {}

    @MainActor
    func shareItem(_ item: Item) {
        let cardView = ShareCardView(item: item)
        guard let image = ShareCardRenderer.render(view: cardView) else { return }

        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
