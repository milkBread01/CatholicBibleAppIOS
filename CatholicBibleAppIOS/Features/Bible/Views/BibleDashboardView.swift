// ============================================
// File: Features/Bible/Views/BibleDashboardView.swift
// ============================================
import SwiftUI

struct BibleDashboardView: View {
    @StateObject private var viewModel = BibleViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.currentTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Search prompt card
                        searchPromptCard
                        
                        // Read the Word button
                        readTheWordButton
                        
                        // Testament sections
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        } else {
                            testamentSections
                        }
                        
                        // Bookmarks and Highlights
                        bookmarksSection
                        
                        // Ad space
                        adSpace
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .padding(.bottom, 80)
                }
            }
            .navigationTitle("Select Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.toggleSearch) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(themeManager.currentTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingSearch) {
                BibleSearchView(viewModel: viewModel)
                    .environmentObject(themeManager)
            }
            // Value-based navigation destination for BibleBook
            .navigationDestination(for: BibleBook.self) { book in
                BookSelectedView(book: book)
                    .environmentObject(themeManager)
            }
        }
    }
    
    // MARK: - View Components
    
    private var searchPromptCard: some View {
        Button(action: viewModel.searchTheBible) {
            VStack(spacing: 8) {
                Text("Want to search for verses directly?")
                    .font(.scaledHeadline(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.primaryText)
                
                Text("[Search the Bible]")
                    .font(.scaledSubheadline(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.accent)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .themedCardStyle(themeManager.currentTheme)
    }
    
    private var readTheWordButton: some View {
        Button(action: viewModel.readTheWord) {
            Text("Read the Word (header)")
                .font(.scaledHeadline(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.primaryText)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .themedCardStyle(themeManager.currentTheme)
    }
    
    private var testamentSections: some View {
        ForEach(viewModel.bookSections) { section in
            VStack(spacing: 12) {
                // Testament header
                TestamentHeader(
                    title: section.testament.displayName,
                    isExpanded: viewModel.selectedTestament == section.testament
                ) {
                    withAnimation {
                        if viewModel.selectedTestament == section.testament {
                            viewModel.selectedTestament = nil
                        } else {
                            viewModel.selectTestament(section.testament)
                        }
                    }
                }
                
                // Books list (collapsible)
                if viewModel.selectedTestament == section.testament {
                    BooksListView(
                        books: section.books,
                        theme: themeManager.currentTheme,
                        fontSize: themeManager.fontSize,
                        onBookTap: viewModel.bookTapped
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
        }
    }
    
    private var bookmarksSection: some View {
        VStack(spacing: 12) {
            TestamentHeader(
                title: "Bookmarks and Highlights",
                isExpanded: false
            ) {
                // No action - just a header
            }
            
            VStack(spacing: 0) {
                BookmarkButton(
                    title: "Bookmarks",
                    action: viewModel.viewBookmarks
                )
                
                Divider()
                    .background(themeManager.currentTheme.divider)
                
                BookmarkButton(
                    title: "Highlights",
                    action: viewModel.viewHighlights
                )
            }
            .themedCardStyle(themeManager.currentTheme)
        }
    }
    
    private var adSpace: some View {
        Rectangle()
            .fill(themeManager.currentTheme.tertiaryBackground)
            .frame(height: 100)
            .overlay(
                Text("AD")
                    .foregroundColor(themeManager.currentTheme.secondaryText)
            )
            .cornerRadius(8)
    }
}

// MARK: - Supporting Views

struct TestamentHeader: View {
    let title: String
    let isExpanded: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.scaledHeadline(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.primaryText)
                
                Spacer()
                
                if isExpanded {
                    Image(systemName: "chevron.down")
                        .foregroundColor(themeManager.currentTheme.secondaryText)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .themedCardStyle(themeManager.currentTheme)
    }
}

struct BooksListView: View {
    let books: [BibleBook]
    let theme: AppTheme
    let fontSize: FontSize
    let onBookTap: (BibleBook) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(books) { book in
                // Use NavigationLink(value:) for value-based navigation
                NavigationLink(value: book) {
                    HStack {
                        Text(book.name)
                            .font(.scaledBody(fontSize))
                            .foregroundColor(theme.primaryText)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(theme.secondaryText)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                
                if book.id != books.last?.id {
                    Divider()
                        .background(theme.divider)
                }
            }
        }
        .background(theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: theme.shadow, radius: 5, x: 0, y: 2)
    }
}

struct BookmarkButton: View {
    let title: String
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.scaledBody(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.primaryText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.secondaryText)
            }
            .padding()
        }
        .background(themeManager.currentTheme.cardBackground)
    }
}

