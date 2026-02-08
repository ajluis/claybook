import SwiftUI

struct AutocompleteField: View {
    let title: String
    @Binding var text: String
    var suggestions: [String] = []
    var recentlyUsed: [String] = []

    @State private var showSuggestions = false
    @FocusState private var isFocused: Bool

    var filteredSuggestions: [String] {
        guard !text.isEmpty else { return recentlyUsed }
        return suggestions.filter { $0.localizedCaseInsensitiveContains(text) }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(title, text: $text)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .onChange(of: isFocused) { _, focused in
                    showSuggestions = focused
                }

            if showSuggestions && !filteredSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(filteredSuggestions, id: \.self) { suggestion in
                        Button {
                            text = suggestion
                            showSuggestions = false
                            isFocused = false
                        } label: {
                            Text(suggestion)
                                .font(.body)
                                .foregroundStyle(Color.theme.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                        }

                        if suggestion != filteredSuggestions.last {
                            Divider()
                        }
                    }
                }
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }
        }
    }
}
