import SwiftUI

struct AppHeader: View {
    @ObservedObject private var theme = ThemeManager.shared
    
    var body: some View {
        HStack {
            Text("App Name")
                .font(.scaledTitle(theme.fontSize))
                .foregroundColor(theme.currentTheme.primaryText)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(theme.currentTheme.secondaryBackground)
        .overlay(Divider().background(theme.currentTheme.divider), alignment: .bottom)
    }
}

struct AppFooter: View {
    @ObservedObject private var theme = ThemeManager.shared

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }

            Text("Library")
                .tabItem { Label("Library", systemImage: "books.vertical") }

            Text("Bible")
                .tabItem { Label("Bible", systemImage: "book") }

            Text("Calendar")
                .tabItem { Label("Calendar", systemImage: "calendar") }

            Text("Settings")
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .accentColor(theme.currentTheme.accent)
        .background(theme.currentTheme.background)
    }
}

