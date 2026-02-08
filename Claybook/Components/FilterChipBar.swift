import SwiftUI

struct FilterChip: Identifiable {
    let id = UUID()
    let label: String
    var isSelected: Bool = false
}

struct FilterChipBar: View {
    @Binding var chips: [FilterChip]
    var allowsMultipleSelection: Bool = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(chips.indices, id: \.self) { index in
                    let chip = chips[index]

                    Button {
                        if allowsMultipleSelection {
                            chips[index].isSelected.toggle()
                        } else {
                            for i in chips.indices {
                                chips[i].isSelected = (i == index) ? !chips[i].isSelected : false
                            }
                        }
                    } label: {
                        Text(chip.label)
                            .font(.subheadline)
                            .foregroundStyle(chip.isSelected ? .white : Color.theme.textPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(chip.isSelected ? Color.theme.primary : Color.theme.surfaceSecondary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, Constants.Layout.horizontalPadding)
        }
    }
}
