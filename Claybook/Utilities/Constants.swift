import SwiftUI

enum Constants {
    // MARK: - Photo Dimensions
    enum Photo {
        static let maxOriginalDimension: CGFloat = 2048
        static let thumbnailDimension: CGFloat = 300
        static let jpegQuality: CGFloat = 0.85
        static let thumbnailJpegQuality: CGFloat = 0.7
    }

    // MARK: - Grid
    enum Grid {
        static let columns = 2
        static let spacing: CGFloat = 12
        static let cardCornerRadius: CGFloat = 12
    }

    // MARK: - Layout
    enum Layout {
        static let minTapTarget: CGFloat = 44
        static let buttonHeight: CGFloat = 56
        static let horizontalPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let fabSize: CGFloat = 60
    }

    // MARK: - Thumbnail Cache
    enum Cache {
        static let thumbnailLimit = 100
    }

    // MARK: - Preset Color Palette (24 colors, 6 rows x 4)
    static let glazeColorPalette: [(name: String, hex: String)] = [
        // Row 1: Whites & Creams
        ("Snow White", "#F5F5F0"),
        ("Cream", "#F5E6CC"),
        ("Ivory", "#EEDFCC"),
        ("Pearl", "#E8E0D8"),

        // Row 2: Browns & Tans
        ("Honey", "#D4A564"),
        ("Caramel", "#C68642"),
        ("Chocolate", "#5C3A21"),
        ("Espresso", "#3C2415"),

        // Row 3: Blues
        ("Sky Blue", "#87CEEB"),
        ("Cobalt", "#0047AB"),
        ("Midnight", "#191970"),
        ("Celadon Blue", "#ACE5EE"),

        // Row 4: Greens
        ("Sage", "#8B9D77"),
        ("Celadon Green", "#ACE1AF"),
        ("Forest", "#355E3B"),
        ("Olive", "#808000"),

        // Row 5: Reds & Oranges
        ("Terracotta", "#C2694F"),
        ("Rust", "#B7410E"),
        ("Copper Red", "#CB6D51"),
        ("Sunset", "#FAD6A5"),

        // Row 6: Others
        ("Lavender", "#B4A7D6"),
        ("Slate", "#708090"),
        ("Charcoal", "#36454F"),
        ("Obsidian", "#1C1C1C"),
    ]
}
