//
//  Card.swift
//  CatholicBibleAppIOS
//
//  Created by Norma Guzman on 11/9/25.
//

// DesignSystem/Components/Card.swift
import SwiftUI

struct Card<Content: View>: View {
    let title: String?
    @ViewBuilder var content: Content

    init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title; self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            if let title { Text(title).font(AppFont.h2()) }
            content
        }
        .padding(Spacing.m)
        .background(AppColor.surface)
        .cornerRadius(16)
        .shadow(radius: 1, y: 1)
    }
}
