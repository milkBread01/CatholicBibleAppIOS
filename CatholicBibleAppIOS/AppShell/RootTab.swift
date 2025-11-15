// AppShell/RootTabs.swift
import SwiftUI

struct RootTabs: View {
    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("Home", systemImage: "house") }

            NavigationStack { LibraryView() }
                .tabItem { Label("Library", systemImage: "books.vertical") }

            NavigationStack { BibleDashboardView() }
                .tabItem { Label("Bible", systemImage: "book") }

            NavigationStack { Text("Calendar") }
                .tabItem { Label("Calendar", systemImage: "calendar") }

            NavigationStack { SettingsView() }
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
