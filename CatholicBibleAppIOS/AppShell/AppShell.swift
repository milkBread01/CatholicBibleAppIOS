//
//  AppShell.swift
//  CatholicBibleAppIOS
//
//  Created by Norma Guzman on 11/9/25.
//

// AppShell/AppShell.swift
import SwiftUI

struct AppHeader: View {
    var body: some View {
        HStack {
            Text("App Name").font(AppFont.h1())
            Spacer()
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .background(AppColor.surface)
        .overlay(Divider(), alignment: .bottom)
    }
}

struct AppFooter: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("Home", systemImage: "house") }
            Text("Library").tabItem { Label("Library", systemImage: "books.vertical") }
            Text("Bible").tabItem { Label("Bible", systemImage: "book") }
            Text("Calendar").tabItem { Label("Calendar", systemImage: "calendar") }
            Text("Settings").tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
