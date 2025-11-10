import SwiftUI

struct SectionHeader: View {
    @ObservedObject private var theme = ThemeManager.shared
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.scaledCaption(theme.fontSize))
            .foregroundColor(theme.currentTheme.secondaryText)
            .padding(.horizontal, 16)
    }
}
