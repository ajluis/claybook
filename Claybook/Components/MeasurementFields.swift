import SwiftUI

struct MeasurementFields: View {
    @Binding var height: String
    @Binding var width: String
    @Binding var topDiameter: String
    @Binding var bottomDiameter: String
    let unit: MeasurementUnit

    @State private var showMore = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Height")
                        .font(.caption)
                        .foregroundStyle(Color.theme.textSecondary)
                    HStack(spacing: 4) {
                        TextField("0", text: $height)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        Text(unit.abbreviation)
                            .font(.caption)
                            .foregroundStyle(Color.theme.textSecondary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Width")
                        .font(.caption)
                        .foregroundStyle(Color.theme.textSecondary)
                    HStack(spacing: 4) {
                        TextField("0", text: $width)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        Text(unit.abbreviation)
                            .font(.caption)
                            .foregroundStyle(Color.theme.textSecondary)
                    }
                }
            }

            if showMore {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Top \u{2300}")
                            .font(.caption)
                            .foregroundStyle(Color.theme.textSecondary)
                        HStack(spacing: 4) {
                            TextField("0", text: $topDiameter)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            Text(unit.abbreviation)
                                .font(.caption)
                                .foregroundStyle(Color.theme.textSecondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bottom \u{2300}")
                            .font(.caption)
                            .foregroundStyle(Color.theme.textSecondary)
                        HStack(spacing: 4) {
                            TextField("0", text: $bottomDiameter)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            Text(unit.abbreviation)
                                .font(.caption)
                                .foregroundStyle(Color.theme.textSecondary)
                        }
                    }
                }
            }

            Button {
                withAnimation { showMore.toggle() }
            } label: {
                Label(
                    showMore ? "Less measurements" : "More measurements",
                    systemImage: showMore ? "chevron.up" : "chevron.down"
                )
                .font(.caption)
                .foregroundStyle(Color.theme.textSecondary)
            }
        }
    }
}
