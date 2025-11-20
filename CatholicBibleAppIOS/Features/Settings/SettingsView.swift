import SwiftUI

struct SettingsView: View {
    //@ObservedObject var themeManager = ThemeManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @State private var notificationsEnabled = false
    @State private var locationEnabled = false
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Appearance Section
                Section(header: Text("Appearance")) {
                    // Theme Selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Theme")
                            .font(.scaledHeadline(themeManager.fontSize))
                            .foregroundColor(themeManager.currentTheme.secondaryText)
                        
                        HStack(spacing: 15) {
                            ForEach(ThemeType.allCases, id: \.self) { themeType in
                                ThemeOptionButton(
                                    themeType: themeType,
                                    isSelected: themeManager.currentTheme.type == themeType,
                                    action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            themeManager.setTheme(themeType)
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(themeManager.currentTheme.cardBackground)
                    
                    // Font Size Selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Font Size")
                            .font(.scaledHeadline(themeManager.fontSize))
                            .foregroundColor(themeManager.currentTheme.secondaryText)
                        
                        VStack(spacing: 10) {
                            ForEach(FontSize.allCases, id: \.self) { size in
                                FontSizeOptionRow(
                                    fontSize: size,
                                    isSelected: themeManager.fontSize == size,
                                    currentTheme: themeManager.currentTheme,
                                    action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            themeManager.setFontSize(size)
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(themeManager.currentTheme.cardBackground)
                }
                
                // MARK: - Reading Preferences Section
                Section(header: Text("Reading Preferences")) {
                    NavigationLink(destination: TextPreviewView()) {
                        HStack {
                            Image(systemName: "textformat.size")
                                .foregroundColor(themeManager.currentTheme.accent)
                            Text("Preview Text Appearance")
                                .font(.scaledBody(themeManager.fontSize))
                        }
                    }
                    .listRowBackground(themeManager.currentTheme.cardBackground)
                }
                
                // MARK: - Notifications Section
                Section(header: Text("Notifications")) {
                    Toggle(isOn: $notificationsEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(themeManager.currentTheme.accent)
                            Text("Daily Reminders")
                                .font(.scaledBody(themeManager.fontSize))
                        }
                    }
                    .listRowBackground(themeManager.currentTheme.cardBackground)
                    
                    if notificationsEnabled {
                        NavigationLink(destination: NotificationSettingsView()) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(themeManager.currentTheme.accent)
                                Text("Reminder Time")
                                    .font(.scaledBody(themeManager.fontSize))
                            }
                        }
                        .listRowBackground(themeManager.currentTheme.cardBackground)
                    }
                }
                
                // MARK: - Location Section
                Section(header: Text("Location Services")) {
                    Toggle(isOn: $locationEnabled) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(themeManager.currentTheme.accent)
                            Text("Enable Location")
                                .font(.scaledBody(themeManager.fontSize))
                        }
                    }
                    .listRowBackground(themeManager.currentTheme.cardBackground)
                    
                    Text("Used to find nearby parishes and Mass times")
                        .font(.scaledCaption(themeManager.fontSize))
                        .foregroundColor(themeManager.currentTheme.secondaryText)
                        .listRowBackground(themeManager.currentTheme.cardBackground)
                }
                
                // MARK: - Account Section
                Section(header: Text("Account")) {
                    NavigationLink(destination: AccountStatusView()) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(themeManager.currentTheme.accent)
                            Text("Account Status")
                                .font(.scaledBody(themeManager.fontSize))
                        }
                    }
                    .listRowBackground(themeManager.currentTheme.cardBackground)
                }
                
                // MARK: - Data Management Section
                Section(header: Text("Data Management")) {
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.red)
                            Text("Reset All Settings")
                                .font(.scaledBody(themeManager.fontSize))
                                .foregroundColor(.red)
                        }
                    }
                    .listRowBackground(themeManager.currentTheme.cardBackground)
                }
                
                // MARK: - About Section
                Section(header: Text("About")) {
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(themeManager.currentTheme.accent)
                            Text("About This App")
                                .font(.scaledBody(themeManager.fontSize))
                        }
                    }
                    .listRowBackground(themeManager.currentTheme.cardBackground)
                    
                    HStack {
                        Text("Version")
                            .font(.scaledBody(themeManager.fontSize))
                        Spacer()
                        Text("1.0.0")
                            .font(.scaledBody(themeManager.fontSize))
                            .foregroundColor(themeManager.currentTheme.secondaryText)
                    }
                    .listRowBackground(themeManager.currentTheme.cardBackground)
                }
            }
            .navigationTitle("Settings")
            .background(themeManager.currentTheme.background)
            .scrollContentBackground(.hidden)
            .alert("Reset Settings", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllSettings()
                }
            } message: {
                Text("This will reset all settings to their default values. Your bookmarks and highlights will not be affected.")
            }
        }
    }
    
    private func resetAllSettings() {
        themeManager.setTheme(.light)
        themeManager.setFontSize(.medium)
        notificationsEnabled = false
        locationEnabled = false
        // Add other reset logic as needed
    }
}

// MARK: - Theme Option Button
struct ThemeOptionButton: View {
    let themeType: ThemeType
    let isSelected: Bool
    let action: () -> Void
    
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(themeBackgroundColor)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: themeType.icon)
                        .font(.title2)
                        .foregroundColor(themeIconColor)
                    
                    if isSelected {
                        Circle()
                            .strokeBorder(themeManager.currentTheme.accent, lineWidth: 3)
                            .frame(width: 60, height: 60)
                    }
                }
                
                Text(themeType.displayName)
                    .font(.scaledCaption(themeManager.fontSize))
                    .foregroundColor(isSelected ? themeManager.currentTheme.primaryText : themeManager.currentTheme.secondaryText)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var themeBackgroundColor: Color {
        switch themeType {
        case .light:
            return Color.white
        case .dark:
            return Color(red: 0.15, green: 0.15, blue: 0.16)
        case .sepia:
            return Color(red: 0.97, green: 0.93, blue: 0.85)
        }
    }
    
    private var themeIconColor: Color {
        switch themeType {
        case .light:
            return .orange
        case .dark:
            return .yellow
        case .sepia:
            return Color(red: 0.6, green: 0.3, blue: 0.1)
        }
    }
}

// MARK: - Font Size Option Row
struct FontSizeOptionRow: View {
    let fontSize: FontSize
    let isSelected: Bool
    let currentTheme: AppTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("Sample Text")
                    .font(.system(size: fontSize.body))
                
                Spacer()
                
                Text(fontSize.displayName)
                    .font(.scaledCaption(fontSize))
                    .foregroundColor(currentTheme.secondaryText)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(currentTheme.accent)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Text Preview View
struct TextPreviewView: View {
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Preview")
                    .font(.scaledTitle(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.primaryText)
                
                Text("This is how your Bible text will appear with the current theme and font size settings.")
                    .font(.scaledBody(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.secondaryText)
                
                Divider()
                
                Text("Sample Bible Text")
                    .font(.scaledTitle2(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.primaryText)
                
                Text("In the beginning God created heaven and earth. And the earth was void and empty, and darkness was upon the face of the deep; and the spirit of God moved over the waters. And God said: Be light made. And light was made.")
                    .font(.scaledBody(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.primaryText)
                    .lineSpacing(8)
                
                Text("— Genesis 1:1-3 (Douay-Rheims)")
                    .font(.scaledCaption(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.secondaryText)
                    .italic()
            }
            .padding()
        }
        .background(themeManager.currentTheme.background)
        .navigationTitle("Text Preview")
    }
}

// MARK: - Placeholder Views
struct NotificationSettingsView: View {
    var body: some View {
        Text("Notification Settings - Coming Soon")
            .navigationTitle("Daily Reminders")
    }
}

struct AccountStatusView: View {
    var body: some View {
        Text("Account Status - Coming Soon")
            .navigationTitle("Account")
    }
}

struct AboutView: View {
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Catholic Companion")
                    .font(.scaledTitle(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.primaryText)
                
                Text("A comprehensive Catholic Bible and prayer companion app.")
                    .font(.scaledBody(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.secondaryText)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Features")
                        .font(.scaledTitle2(themeManager.fontSize))
                        .foregroundColor(themeManager.currentTheme.primaryText)
                    
                    Text("• Douay-Rheims Bible with notes")
                    Text("• Baltimore Catechism")
                    Text("• Summa Theologica")
                    Text("• Interactive Rosary")
                    Text("• Daily Mass readings")
                    Text("• Parish finder")
                }
                .font(.scaledBody(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.primaryText)
                
                Divider()
                
                Text("All content is from public domain sources.")
                    .font(.scaledCaption(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.secondaryText)
            }
            .padding()
        }
        .background(themeManager.currentTheme.background)
        .navigationTitle("About")
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
