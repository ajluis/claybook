import SwiftUI

struct ThemeColors {
    // Primary
    let primary = Color(hex: "#C2694F")        // Terracotta
    let primaryDark = Color(hex: "#9E4B35")    // Deep terracotta
    let secondary = Color(hex: "#8B9D77")      // Sage green
    let secondaryDark = Color(hex: "#6B7D5A")  // Deep sage

    // Backgrounds
    let background = Color(hex: "#FAF6F1")     // Warm cream
    let surface = Color(hex: "#FFFFFF")         // White
    let surfaceSecondary = Color(hex: "#F3EDE5") // Light tan

    // Text
    let textPrimary = Color(hex: "#2C2420")    // Dark brown
    let textSecondary = Color(hex: "#6B5E54")  // Medium brown
    let textTertiary = Color(hex: "#A09389")   // Light brown

    // Accents
    let accent = Color(hex: "#D4A574")         // Golden clay
    let warning = Color(hex: "#D4874D")        // Orange
    let destructive = Color(hex: "#C45B4A")    // Red-brown
    let success = Color(hex: "#6B9B6B")        // Muted green

    // Stage colors
    let stageMade = Color(hex: "#C2694F")      // Terracotta
    let stageDrying = Color(hex: "#D4A574")    // Golden
    let stageBisque = Color(hex: "#D4874D")    // Orange
    let stageGlazed = Color(hex: "#8B9D77")    // Sage
    let stageGlazeKiln = Color(hex: "#7B8EC4") // Blue
    let stageFinished = Color(hex: "#6B9B6B")  // Green
}

extension Color {
    static let theme = ThemeColors()

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
