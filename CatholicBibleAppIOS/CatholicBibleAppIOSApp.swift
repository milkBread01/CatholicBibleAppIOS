
import SwiftUI
import SwiftData

@main
struct CatholicBibleAppIOSApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    var body: some Scene {
        WindowGroup {
            // If you want tabs as the root, replace with AppFooter()
            RootTabs()
                .environmentObject(themeManager)
        }
        
    }
}

