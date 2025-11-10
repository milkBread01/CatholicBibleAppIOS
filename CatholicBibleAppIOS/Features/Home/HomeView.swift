import SwiftUI

struct HomeView: View {
    @ObservedObject var themeManager = ThemeManager.shared
    @State private var currentQuote: DailyQuote = DailyQuote.placeholder()
    @State private var seasonalCard: SeasonalCard = SeasonalCard.placeholder()
    @State private var todaysInvitation: String = "Come to me, all you who labor and are burdened, and I will give you rest."
    @State private var dailyReading: DailyReading = DailyReading.placeholder()
    @State private var todaysRosary: String = "Joyful Mysteries"
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Quote Section
                    DailyQuoteCard(quote: currentQuote)
                        .padding(.horizontal)
                    
                    // Seasonal Card
                    SeasonalCardView(card: seasonalCard)
                        .padding(.horizontal)
                    
                    // Today's Invitation
                    TodaysInvitationView(invitation: todaysInvitation)
                        .padding(.horizontal)
                    
                    // Daily Reading and Rosary Row
                    HStack(spacing: 15) {
                        DailyReadingButton(reading: dailyReading)
                        TodaysRosaryButton(mystery: todaysRosary)
                    }
                    .padding(.horizontal)
                    
                    // Mass Schedule
                    MassScheduleCard()
                        .padding(.horizontal)
                    
                    // This Week's Readings
                    WeeklyReadingsCard()
                        .padding(.horizontal)
                    
                    // Find Your Parish
                    FindParishButton()
                        .padding(.horizontal)
                    
                    // Ad Space (Placeholder)
                    AdPlaceholder()
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
                .padding(.top, 10)
            }
            .background(themeManager.currentTheme.background.ignoresSafeArea())
            .navigationTitle("Catholic Companion")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            loadDailyContent()
        }
    }
    
    private func loadDailyContent() {
        // TODO: Load daily quote from local JSON file
        // TODO: Determine current liturgical season and load appropriate card
        // TODO: Load today's Mass readings
        // TODO: Determine today's Rosary mystery based on day of week
    }
}

// MARK: - Daily Quote Card
struct DailyQuoteCard: View {
    let quote: DailyQuote
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Quote")
                .font(.scaledHeadline(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.secondaryText)
            
            Text(quote.text)
                .font(.scaledBody(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.primaryText)
                .italic()
                .lineSpacing(4)
            
            Text("— \(quote.source)")
                .font(.scaledCaption(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .themedCardStyle(themeManager.currentTheme)
    }
}

// MARK: - Seasonal Card
struct SeasonalCardView: View {
    let card: SeasonalCard
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: card.iconName)
                    .font(.title)
                    .foregroundColor(card.color)
                
                Text(card.title)
                    .font(.scaledTitle2(themeManager.fontSize))
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.currentTheme.primaryText)
                
                Spacer()
            }
            
            Text(card.message)
                .font(.scaledBody(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.primaryText)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [card.color.opacity(0.1), card.color.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(card.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Today's Invitation
struct TodaysInvitationView: View {
    let invitation: String
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Invitation")
                .font(.scaledHeadline(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.secondaryText)
            
            Text(invitation)
                .font(.scaledSubheadline(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(themeManager.currentTheme.secondaryBackground)
        .cornerRadius(8)
    }
}

// MARK: - Daily Reading Button
struct DailyReadingButton: View {
    let reading: DailyReading
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationLink(destination: DailyReadingDetailView(reading: reading)) {
            VStack(spacing: 8) {
                Image(systemName: "book.fill")
                    .font(.title2)
                    .foregroundColor(themeManager.currentTheme.accent)
                
                Text("Daily Reading")
                    .font(.scaledCaption(themeManager.fontSize))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(themeManager.currentTheme.primaryText)
                
                Text(reading.bookAndChapter)
                    .font(.scaledCaption2(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .themedCardStyle(themeManager.currentTheme)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Today's Rosary Button
struct TodaysRosaryButton: View {
    let mystery: String
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationLink(destination: RosaryView(mystery: mystery)) {
            VStack(spacing: 8) {
                Image(systemName: "circle.grid.cross.fill")
                    .font(.title2)
                    .foregroundColor(themeManager.currentTheme.secondaryAccent)
                
                Text("Today's Rosary")
                    .font(.scaledCaption(themeManager.fontSize))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(themeManager.currentTheme.primaryText)
                
                Text(mystery)
                    .font(.scaledCaption2(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .themedCardStyle(themeManager.currentTheme)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Mass Schedule Card
struct MassScheduleCard: View {
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationLink(destination: MassScheduleView()) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mass Schedule")
                        .font(.scaledHeadline(themeManager.fontSize))
                        .foregroundColor(themeManager.currentTheme.primaryText)
                    
                    Text("View nearby Mass times")
                        .font(.scaledCaption(themeManager.fontSize))
                        .foregroundColor(themeManager.currentTheme.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(themeManager.currentTheme.secondaryText)
            }
            .padding()
            .themedCardStyle(themeManager.currentTheme)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Weekly Readings Card
struct WeeklyReadingsCard: View {
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationLink(destination: WeeklyReadingsView()) {
            VStack(alignment: .leading, spacing: 12) {
                Text("This Week's Readings")
                    .font(.scaledHeadline(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.primaryText)
                
                VStack(alignment: .leading, spacing: 8) {
                    WeeklyReadingRow(day: "Sunday", reading: "Matthew 5:1-12")
                    WeeklyReadingRow(day: "Monday", reading: "Mark 1:14-20")
                    WeeklyReadingRow(day: "Tuesday", reading: "Luke 10:1-9")
                }
            }
            .padding()
            .themedCardStyle(themeManager.currentTheme)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WeeklyReadingRow: View {
    let day: String
    let reading: String
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack {
            Text(day)
                .font(.scaledSubheadline(themeManager.fontSize))
                .fontWeight(.medium)
                .foregroundColor(themeManager.currentTheme.primaryText)
                .frame(width: 80, alignment: .leading)
            
            Text(reading)
                .font(.scaledCaption(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.secondaryText)
            
            Spacer()
        }
    }
}

// MARK: - Find Parish Button
struct FindParishButton: View {
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        Button(action: {
            // TODO: Navigate to parish finder or trigger location-based search
        }) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.title2)
                        .foregroundColor(.red)
                    
                    Text("FIND YOUR PARISH")
                        .font(.scaledHeadline(themeManager.fontSize))
                        .foregroundColor(themeManager.currentTheme.primaryText)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(themeManager.currentTheme.secondaryText)
                }
                
                Text("[Find Nearby Parishes]")
                    .font(.scaledSubheadline(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
            }
            .padding()
            .themedCardStyle(themeManager.currentTheme)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Ad Placeholder
struct AdPlaceholder: View {
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(themeManager.currentTheme.tertiaryBackground)
                .frame(height: 100)
                .cornerRadius(8)
            
            Text("AD")
                .font(.scaledTitle3(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.secondaryText)
        }
    }
}

// MARK: - Data Models

struct DailyQuote {
    let text: String
    let source: String
    
    static func placeholder() -> DailyQuote {
        return DailyQuote(
            text: "The Eucharist is the source and summit of the Christian life.",
            source: "St. Thomas Aquinas, Summa Theologica"
        )
    }
}

struct SeasonalCard {
    let title: String
    let message: String
    let iconName: String
    let color: Color
    
    static func placeholder() -> SeasonalCard {
        // TODO: Determine current liturgical season
        return SeasonalCard(
            title: "Ordinary Time",
            message: "Let us grow in faith and love as we follow Christ in our daily lives.",
            iconName: "leaf.fill",
            color: .green
        )
    }
}

struct DailyReading {
    let bookAndChapter: String
    let fullReference: String
    
    static func placeholder() -> DailyReading {
        return DailyReading(
            bookAndChapter: "Matthew 5",
            fullReference: "Matthew 5:1-12"
        )
    }
}

// MARK: - Placeholder Destination Views

struct DailyReadingDetailView: View {
    let reading: DailyReading
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        Text("Daily Reading: \(reading.fullReference)")
            .font(.scaledBody(themeManager.fontSize))
            .foregroundColor(themeManager.currentTheme.primaryText)
            .navigationTitle("Daily Reading")
    }
}

struct RosaryView: View {
    let mystery: String
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        Text("Interactive Rosary: \(mystery)")
            .font(.scaledBody(themeManager.fontSize))
            .foregroundColor(themeManager.currentTheme.primaryText)
            .navigationTitle("Rosary")
    }
}

struct MassScheduleView: View {
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        Text("Mass Schedule View - Coming Soon")
            .font(.scaledBody(themeManager.fontSize))
            .foregroundColor(themeManager.currentTheme.primaryText)
            .navigationTitle("Mass Schedule")
    }
}

struct WeeklyReadingsView: View {
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        Text("Weekly Readings View - Coming Soon")
            .font(.scaledBody(themeManager.fontSize))
            .foregroundColor(themeManager.currentTheme.primaryText)
            .navigationTitle("This Week's Readings")
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
