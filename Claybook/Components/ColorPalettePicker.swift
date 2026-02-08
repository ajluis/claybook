import SwiftUI

struct ColorPalettePicker: View {
    @Binding var selectedColors: [(name: String, hex: String)]

    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Constants.glazeColorPalette, id: \.hex) { color in
                let isSelected = selectedColors.contains { $0.hex == color.hex }

                VStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: color.hex))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.theme.primary : Color.theme.textTertiary.opacity(0.2), lineWidth: isSelected ? 3 : 1)
                        )
                        .overlay {
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundStyle(color.hex == "#F5F5F0" || color.hex == "#F5E6CC" || color.hex == "#EEDFCC" || color.hex == "#E8E0D8" || color.hex == "#FAD6A5" ? .black : .white)
                            }
                        }

                    Text(color.name)
                        .font(.caption2)
                        .foregroundStyle(Color.theme.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .onTapGesture {
                    if isSelected {
                        selectedColors.removeAll { $0.hex == color.hex }
                    } else {
                        selectedColors.append(color)
                    }
                }
            }
        }
    }
}
