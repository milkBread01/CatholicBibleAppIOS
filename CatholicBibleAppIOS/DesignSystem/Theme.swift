import SwiftUI
import Combine

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme
    @Published var fontSize: FontSize
    
    private let themeKey = "selectedTheme"
    private let fontSizeKey = "selectedFontSize"
    
    init() {
        // Load saved theme preference
        if let savedThemeRaw = UserDefaults.standard.string(forKey: themeKey),
           let savedTheme = ThemeType(rawValue: savedThemeRaw) {
            self.currentTheme = AppTheme.getTheme(for: savedTheme)
        } else {
            self.currentTheme = AppTheme.light
        }
        
        // Load saved font size preference
        if let savedFontSizeRaw = UserDefaults.standard.string(forKey: fontSizeKey),
           let savedFontSize = FontSize(rawValue: savedFontSizeRaw) {
            self.fontSize = savedFontSize
        } else {
            self.fontSize = .medium
        }
    }
    
    func setTheme(_ themeType: ThemeType) {
        currentTheme = AppTheme.getTheme(for: themeType)
        UserDefaults.standard.set(themeType.rawValue, forKey: themeKey)
    }
    
    func setFontSize(_ size: FontSize) {
        fontSize = size
        UserDefaults.standard.set(size.rawValue, forKey: fontSizeKey)
    }
    
    func toggleTheme() {
        let newTheme: ThemeType = currentTheme.type == .light ? .dark : .light
        setTheme(newTheme)
    }
}

// MARK: - Theme Type Enum
enum ThemeType: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case sepia = "sepia"
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .sepia: return "Sepia"
        }
    }
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .sepia: return "book.fill"
        }
    }
}

// MARK: - Font Size Enum
enum FontSize: String, CaseIterable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case extraLarge = "extraLarge"
    
    var displayName: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        case .extraLarge: return "Extra Large"
        }
    }
    
    var scale: CGFloat {
        switch self {
        case .small: return 0.85
        case .medium: return 1.0
        case .large: return 1.15
        case .extraLarge: return 1.3
        }
    }
    
    // Body text sizes
    var body: CGFloat {
        return 16 * scale
    }
    
    // Title text sizes
    var title: CGFloat {
        return 24 * scale
    }
    
    var title2: CGFloat {
        return 20 * scale
    }
    
    var title3: CGFloat {
        return 18 * scale
    }
    
    // Other text sizes
    var headline: CGFloat {
        return 17 * scale
    }
    
    var subheadline: CGFloat {
        return 15 * scale
    }
    
    var caption: CGFloat {
        return 12 * scale
    }
    
    var caption2: CGFloat {
        return 11 * scale
    }
    
    var footnote: CGFloat {
        return 13 * scale
    }
}

// MARK: - App Theme Model
struct AppTheme {
    let type: ThemeType
    
    // Background colors
    let background: Color
    let secondaryBackground: Color
    let tertiaryBackground: Color
    
    // Text colors
    let primaryText: Color
    let secondaryText: Color
    let tertiaryText: Color
    
    // Accent colors
    let accent: Color
    let secondaryAccent: Color
    
    // Card colors
    let cardBackground: Color
    let cardBorder: Color
    
    // Liturgical colors (for seasonal cards)
    let liturgicalPurple: Color
    let liturgicalGreen: Color
    let liturgicalRed: Color
    let liturgicalWhite: Color
    let liturgicalGold: Color
    
    // UI element colors
    let divider: Color
    let shadow: Color
    
    static func getTheme(for type: ThemeType) -> AppTheme {
        switch type {
        case .light:
            return AppTheme.light
        case .dark:
            return AppTheme.dark
        case .sepia:
            return AppTheme.sepia
        }
    }
    
    // MARK: - Light Theme
    static let light = AppTheme(
        type: .light,
        background: Color(UIColor.systemBackground),
        secondaryBackground: Color(UIColor.secondarySystemBackground),
        tertiaryBackground: Color(UIColor.tertiarySystemBackground),
        primaryText: Color(UIColor.label),
        secondaryText: Color(UIColor.secondaryLabel),
        tertiaryText: Color(UIColor.tertiaryLabel),
        accent: Color.blue,
        secondaryAccent: Color.purple,
        cardBackground: Color.white,
        cardBorder: Color.gray.opacity(0.2),
        liturgicalPurple: Color(red: 0.5, green: 0.2, blue: 0.6),
        liturgicalGreen: Color(red: 0.2, green: 0.6, blue: 0.3),
        liturgicalRed: Color(red: 0.8, green: 0.1, blue: 0.2),
        liturgicalWhite: Color.white,
        liturgicalGold: Color(red: 1.0, green: 0.84, blue: 0.0),
        divider: Color.gray.opacity(0.3),
        shadow: Color.black.opacity(0.1)
    )
    
    // MARK: - Dark Theme
    static let dark = AppTheme(
        type: .dark,
        background: Color(red: 0.11, green: 0.11, blue: 0.12),
        secondaryBackground: Color(red: 0.17, green: 0.17, blue: 0.18),
        tertiaryBackground: Color(red: 0.22, green: 0.22, blue: 0.23),
        primaryText: Color.white,
        secondaryText: Color.gray,
        tertiaryText: Color(UIColor.tertiaryLabel),
        accent: Color.blue,
        secondaryAccent: Color.purple,
        cardBackground: Color(red: 0.15, green: 0.15, blue: 0.16),
        cardBorder: Color.gray.opacity(0.3),
        liturgicalPurple: Color(red: 0.6, green: 0.3, blue: 0.7),
        liturgicalGreen: Color(red: 0.3, green: 0.7, blue: 0.4),
        liturgicalRed: Color(red: 0.9, green: 0.2, blue: 0.3),
        liturgicalWhite: Color(red: 0.95, green: 0.95, blue: 0.97),
        liturgicalGold: Color(red: 1.0, green: 0.88, blue: 0.2),
        divider: Color.gray.opacity(0.4),
        shadow: Color.black.opacity(0.3)
    )
    
    // MARK: - Sepia Theme (Reading Mode)
    static let sepia = AppTheme(
        type: .sepia,
        background: Color(red: 0.97, green: 0.93, blue: 0.85),
        secondaryBackground: Color(red: 0.94, green: 0.90, blue: 0.82),
        tertiaryBackground: Color(red: 0.91, green: 0.87, blue: 0.79),
        primaryText: Color(red: 0.2, green: 0.15, blue: 0.1),
        secondaryText: Color(red: 0.4, green: 0.35, blue: 0.3),
        tertiaryText: Color(red: 0.5, green: 0.45, blue: 0.4),
        accent: Color(red: 0.6, green: 0.3, blue: 0.1),
        secondaryAccent: Color(red: 0.5, green: 0.2, blue: 0.1),
        cardBackground: Color(red: 0.98, green: 0.94, blue: 0.86),
        cardBorder: Color(red: 0.8, green: 0.7, blue: 0.6),
        liturgicalPurple: Color(red: 0.5, green: 0.2, blue: 0.5),
        liturgicalGreen: Color(red: 0.3, green: 0.5, blue: 0.3),
        liturgicalRed: Color(red: 0.7, green: 0.2, blue: 0.2),
        liturgicalWhite: Color(red: 0.99, green: 0.95, blue: 0.87),
        liturgicalGold: Color(red: 0.9, green: 0.7, blue: 0.2),
        divider: Color(red: 0.7, green: 0.6, blue: 0.5),
        shadow: Color.black.opacity(0.05)
    )
}

// MARK: - View Extension for Theme
extension View {
    func themedBackground(_ theme: AppTheme) -> some View {
        self.background(theme.background.ignoresSafeArea())
    }
    
    func themedCardStyle(_ theme: AppTheme) -> some View {
        self
            .background(theme.cardBackground)
            .cornerRadius(12)
            .shadow(color: theme.shadow, radius: 5, x: 0, y: 2)
    }
}

// MARK: - Font Extension for Scaled Fonts
extension Font {
    static func scaledBody(_ fontSize: FontSize) -> Font {
        return .system(size: fontSize.body)
    }
    
    static func scaledTitle(_ fontSize: FontSize) -> Font {
        return .system(size: fontSize.title, weight: .bold)
    }
    
    static func scaledTitle2(_ fontSize: FontSize) -> Font {
        return .system(size: fontSize.title2, weight: .semibold)
    }
    
    static func scaledTitle3(_ fontSize: FontSize) -> Font {
        return .system(size: fontSize.title3, weight: .semibold)
    }
    
    static func scaledHeadline(_ fontSize: FontSize) -> Font {
        return .system(size: fontSize.headline, weight: .semibold)
    }
    
    static func scaledSubheadline(_ fontSize: FontSize) -> Font {
        return .system(size: fontSize.subheadline)
    }
    
    static func scaledCaption(_ fontSize: FontSize) -> Font {
        return .system(size: fontSize.caption)
    }
    
    static func scaledCaption2(_ fontSize: FontSize) -> Font {
        return .system(size: fontSize.caption2)
    }
    
    static func scaledFootnote(_ fontSize: FontSize) -> Font {
        return .system(size: fontSize.footnote)
    }
}
