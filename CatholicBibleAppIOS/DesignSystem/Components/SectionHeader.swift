

// DesignSystem/Components/SectionHeader.swift
import SwiftUI

struct SectionHeader: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(AppFont.caption(.semibold))
            .foregroundColor(AppColor.subtle)
            .padding(.horizontal, Spacing.m)
    }
}
