import SwiftUI

struct ThemeColors {
    // Primary
    let primary = Color.adaptive(light: "#C2694F", dark: "#D4805F")
    let primaryDark = Color.adaptive(light: "#9E4B35", dark: "#C2694F")
    let secondary = Color.adaptive(light: "#8B9D77", dark: "#9DB389")
    let secondaryDark = Color.adaptive(light: "#6B7D5A", dark: "#8B9D77")

    // Backgrounds
    let background = Color.adaptive(light: "#FAF6F1", dark: "#1A1512")
    let surface = Color.adaptive(light: "#FFFFFF", dark: "#252019")
    let surfaceSecondary = Color.adaptive(light: "#F3EDE5", dark: "#302923")

    // Text
    let textPrimary = Color.adaptive(light: "#2C2420", dark: "#F0E8DF")
    let textSecondary = Color.adaptive(light: "#6B5E54", dark: "#B8A99C")
    let textTertiary = Color.adaptive(light: "#A09389", dark: "#7A6E64")

    // Accents
    let accent = Color.adaptive(light: "#D4A574", dark: "#D4A574")
    let warning = Color.adaptive(light: "#D4874D", dark: "#D4874D")
    let destructive = Color.adaptive(light: "#C45B4A", dark: "#D46B5A")
    let success = Color.adaptive(light: "#6B9B6B", dark: "#7DAF7D")

    // Stage colors — kept vibrant in both modes
    let stageMade = Color.adaptive(light: "#C2694F", dark: "#D4805F")
    let stageDrying = Color.adaptive(light: "#D4A574", dark: "#D4A574")
    let stageBisque = Color.adaptive(light: "#D4874D", dark: "#D4874D")
    let stageGlazed = Color.adaptive(light: "#8B9D77", dark: "#9DB389")
    let stageGlazeKiln = Color.adaptive(light: "#7B8EC4", dark: "#8D9FD4")
    let stageFinished = Color.adaptive(light: "#6B9B6B", dark: "#7DAF7D")
}

extension Color {
    static let theme = ThemeColors()

    static func adaptive(light: String, dark: String) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark)
                : UIColor(hex: light)
        })
    }

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
