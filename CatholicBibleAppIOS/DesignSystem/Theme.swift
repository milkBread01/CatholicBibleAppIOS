

// DesignSystem/Theme.swift
import SwiftUI

enum AppColor {
    static let bg        = Color(.systemBackground)
    static let surface   = Color(.secondarySystemBackground)
    static let primary   = Color("Primary")       // define in Assets
    static let accent    = Color("Accent")        // define in Assets
    static let text      = Color.primary
    static let subtle    = Color.secondary
}

enum AppFont {
    static func h1(_ w: Font.Weight = .semibold) -> Font { .system(size: 28, weight: w) }
    static func h2(_ w: Font.Weight = .semibold) -> Font { .system(size: 22, weight: w) }
    static func body(_ w: Font.Weight = .regular) -> Font { .system(size: 16, weight: w) }
    static func caption(_ w: Font.Weight = .regular) -> Font { .system(size: 13, weight: w) }
}

enum Spacing {
    static let s: CGFloat = 8
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
}
