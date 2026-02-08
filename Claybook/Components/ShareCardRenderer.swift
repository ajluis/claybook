import SwiftUI

struct ShareCardRenderer {
    @MainActor
    static func render(view: some View, size: CGSize = CGSize(width: 400, height: 600)) -> UIImage? {
        let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}
