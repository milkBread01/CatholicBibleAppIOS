import SwiftUI

struct Card<Content: View>: View {
    @ObservedObject private var theme = ThemeManager.shared

    let title: String?
    @ViewBuilder var content: Content

    init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title)
                    .font(.scaledTitle2(theme.fontSize))
                    .foregroundColor(theme.currentTheme.primaryText)
            }
            content
        }
        .padding(16)
        .background(theme.currentTheme.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.currentTheme.cardBorder, lineWidth: 1)
        )
        .cornerRadius(12)
        .shadow(color: theme.currentTheme.shadow, radius: 5, x: 0, y: 2)
    }
}
