// ============================================
// File: Features/Bible/Views/ChapterSelectedView.swift
// ============================================
import SwiftUI

struct ChapterSelectedView: View {
    let book: BibleBook
    let initialChapter: Int
    
    @EnvironmentObject var themeManager: ThemeManager
    @State private var verses: [BibleVerse] = []
    @State private var comments: [BibleComment] = []
    @State private var isLoading: Bool = true
    @State private var currentLanguage: String = "English"
    
    // Chapter navigation
    @State private var currentChapter: Int
    @State private var maxChapterCount: Int = 0
    
    // Highlight & Selection
    @State private var selectedVerses: ClosedRange<Int>?
    @State private var existingHighlights: [BibleHighlight] = []
    @State private var showContextMenu: Bool = false
    @State private var contextMenuPosition: CGPoint = .zero
    @State private var showHighlightSheet: Bool = false
    @State private var editingHighlight: BibleHighlight?
    @State private var highlightSheetFocusNote: Bool = false
    
    // Alerts
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    init(book: BibleBook, chapter: Int) {
        self.book = book
        self.initialChapter = chapter
        self._currentChapter = State(initialValue: chapter)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Top controls section
                    topControlsSection
                    
                    // Language section
                    languageSection
                    
                    // Chapter navigation
                    chapterNavigationSection
                    
                    // Main Bible text area
                    bibleTextSection
                    
                    // Divider
                    Divider()
                        .background(themeManager.currentTheme.divider)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    
                    // Notes/Comments section
                    notesSection
                    
                    // Navigation buttons
                    navigationButtons
                    
                    // Ad space
                    adSpace
                    
                    // Bookmark page button
                    bookmarkButton
                }
                .padding(.bottom, 80)
            }
            .background(themeManager.currentTheme.background.ignoresSafeArea())
            
            // Context Menu Overlay
            if showContextMenu, let selectedRange = selectedVerses {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showContextMenu = false
                        selectedVerses = nil
                    }
                
                ContextMenuView(
                    onHighlight: {
                        highlightSheetFocusNote = false
                        showHighlightSheet = true
                        showContextMenu = false
                    },
                    onAddNote: {
                        highlightSheetFocusNote = true
                        showHighlightSheet = true
                        showContextMenu = false
                    },
                    onBookmark: {
                        bookmarkVerses(selectedRange)
                        showContextMenu = false
                        selectedVerses = nil
                    },
                    onCopy: {
                        copyVerses(selectedRange)
                        showContextMenu = false
                        selectedVerses = nil
                    },
                    onShare: {
                        shareVerses(selectedRange)
                        showContextMenu = false
                    }
                )
                .environmentObject(themeManager)
                .position(contextMenuPosition)
            }
        }
        .navigationTitle(book.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showHighlightSheet) {
            if let selectedRange = selectedVerses {
                HighlightNoteSheet(
                    book: book,
                    chapter: currentChapter,
                    verseRange: selectedRange,
                    verses: verses,
                    existingHighlight: editingHighlight,
                    focusNote: highlightSheetFocusNote,
                    onSave: { highlight in
                        saveHighlight(highlight)
                        showHighlightSheet = false
                        selectedVerses = nil
                        editingHighlight = nil
                    },
                    onRemove: {
                        if let highlight = editingHighlight {
                            removeHighlight(highlight)
                        }
                        showHighlightSheet = false
                        selectedVerses = nil
                        editingHighlight = nil
                    },
                    onCancel: {
                        showHighlightSheet = false
                        selectedVerses = nil
                        editingHighlight = nil
                    }
                )
                .environmentObject(themeManager)
            }
        }
        .alert("Notice", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .task {
            await loadContent()
        }
        .onChange(of: currentChapter) { oldValue, newValue in
            Task {
                await loadContent()
            }
        }
    }
    
    // MARK: - View Components
    
    private var topControlsSection: some View {
        HStack(spacing: 16) {
            // Decrease chapter button
            Button(action: previousChapter) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(currentChapter > 1 ? themeManager.currentTheme.accent : themeManager.currentTheme.secondaryText)
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
                    )
            }
            .disabled(currentChapter <= 1)
            
            Spacer()
            
            Text(book.name)
                .font(.scaledHeadline(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.primaryText)
            
            Spacer()
            
            // Bookmark button
            Button(action: toggleBookmark) {
                Image(systemName: "bookmark")
                    .font(.title3)
                    .foregroundColor(themeManager.currentTheme.accent)
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
                    )
            }
            
            // Increase chapter button
            Button(action: nextChapter) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(maxChapterCount > 0 && currentChapter < maxChapterCount ? themeManager.currentTheme.accent : themeManager.currentTheme.secondaryText)
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
                    )
            }
            .disabled(maxChapterCount > 0 && currentChapter >= maxChapterCount)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    private var languageSection: some View {
        HStack(spacing: 12) {
            Text("Language: \(currentLanguage)")
                .font(.scaledBody(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.primaryText)
                .padding()
                .frame(maxWidth: .infinity)
                .background(themeManager.currentTheme.cardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
                )
            
            Button(action: changeLanguage) {
                Text("Change")
                    .font(.scaledBody(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.primaryText)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(themeManager.currentTheme.cardBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
    
    private var chapterNavigationSection: some View {
        Button(action: showChapterPicker) {
            Text("Chapter \(currentChapter)")
                .font(.scaledBody(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.primaryText)
                .padding()
                .frame(maxWidth: .infinity)
                .background(themeManager.currentTheme.cardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
                )
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
    
    @ViewBuilder
    private var bibleTextSection: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .frame(minHeight: 300)
                .padding()
        } else if verses.isEmpty {
            Text("No verses found.")
                .font(.scaledBody(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.secondaryText)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 300)
                .padding()
        } else {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(verses) { verse in
                    VerseRow(
                        verse: verse,
                        highlight: existingHighlights.first { $0.verseStart <= verse.verse && $0.verseEnd >= verse.verse },
                        isSelected: selectedVerses?.contains(verse.verse) ?? false,
                        theme: themeManager.currentTheme,
                        fontSize: themeManager.fontSize,
                        onTap: {
                            handleVerseTap(verse.verse)
                        }
                    )
                }
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(themeManager.currentTheme.cardBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
            )
            .padding(.horizontal)
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Notes header
            Text("Notes")
                .font(.scaledHeadline(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.primaryText)
                .padding()
                .frame(maxWidth: .infinity)
                .background(themeManager.currentTheme.cardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
                )
            
            // Comments/Notes content
            if comments.isEmpty {
                Text("No notes available for this chapter.")
                    .font(.scaledBody(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.secondaryText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 150)
                    .background(themeManager.currentTheme.cardBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
                    )
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(comments) { comment in
                        VStack(alignment: .leading, spacing: 6) {
                            // Verse reference
                            Text("Verse \(comment.verse)")
                                .font(.scaledCaption(themeManager.fontSize))
                                .foregroundColor(themeManager.currentTheme.accent)
                                .fontWeight(.semibold)
                            
                            // Comment text
                            Text(comment.comment)
                                .font(.scaledBody(themeManager.fontSize))
                                .foregroundColor(themeManager.currentTheme.primaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        if comment.id != comments.last?.id {
                            Divider()
                                .background(themeManager.currentTheme.divider)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(themeManager.currentTheme.cardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 12) {
            Button(action: previousChapter) {
                Text("[Previous]")
                    .font(.scaledBody(themeManager.fontSize))
                    .foregroundColor(currentChapter > 1 ? themeManager.currentTheme.primaryText : themeManager.currentTheme.secondaryText)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(themeManager.currentTheme.cardBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
                    )
            }
            .disabled(currentChapter <= 1)
            
            Button(action: nextChapter) {
                Text("[Next]")
                    .font(.scaledBody(themeManager.fontSize))
                    .foregroundColor(maxChapterCount > 0 && currentChapter < maxChapterCount ? themeManager.currentTheme.primaryText : themeManager.currentTheme.secondaryText)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(themeManager.currentTheme.cardBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
                    )
            }
            .disabled(maxChapterCount > 0 && currentChapter >= maxChapterCount)
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
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
            .padding(.horizontal)
            .padding(.bottom, 12)
    }
    
    private var bookmarkButton: some View {
        Button(action: bookmarkPage) {
            Text("Bookmark Page")
                .font(.scaledHeadline(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.primaryText)
                .padding()
                .frame(maxWidth: .infinity)
                .background(themeManager.currentTheme.cardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
                )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Data Loading
    
    private func loadContent() async {
        isLoading = true
        
        // Load max chapter count
        let maxCount = await BibleRepository.shared.getChapterCount(book: book)
        
        // Load verses and comments
        async let versesTask = BibleRepository.shared.getChapter(book: book, chapter: currentChapter)
        async let commentsTask = BibleRepository.shared.getComments(book: book, chapter: currentChapter)
        
        let (fetchedVerses, fetchedComments) = await (versesTask, commentsTask)
        
        // Load highlights
        let highlights = UserInfoRepository.shared.getHighlights(
            seriesName: book.seriesName,
            bookId: book.id,
            chapter: currentChapter
        )
        
        await MainActor.run {
            self.maxChapterCount = maxCount
            self.verses = fetchedVerses
            self.comments = fetchedComments
            self.existingHighlights = highlights
            self.isLoading = false
        }
    }
    
    // MARK: - Verse Selection Actions
    
    private func handleVerseTap(_ verseNumber: Int) {
        // Check if tapping existing highlight
        if let existingHighlight = existingHighlights.first(where: { $0.verseStart <= verseNumber && $0.verseEnd >= verseNumber }) {
            // Tapping existing highlight - show context menu for editing
            selectedVerses = existingHighlight.verseStart...existingHighlight.verseEnd
            editingHighlight = existingHighlight
        } else {
            // New selection
            selectedVerses = verseNumber...verseNumber
            editingHighlight = nil
        }
        
        // Show context menu
        showContextMenu = true
        
        // Position menu slightly above center
        let screenHeight = UIScreen.main.bounds.height
        contextMenuPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: screenHeight * 0.4)
    }
    
    // MARK: - Highlight Actions
    
    private func saveHighlight(_ highlight: BibleHighlight) {
        let success = UserInfoRepository.shared.saveHighlight(highlight)
        
        if success {
            alertMessage = "Highlight saved successfully!"
            // Reload highlights
            existingHighlights = UserInfoRepository.shared.getHighlights(
                seriesName: book.seriesName,
                bookId: book.id,
                chapter: currentChapter
            )
        } else {
            alertMessage = "Could not save highlight. It may overlap with an existing highlight."
        }
        
        showAlert = true
    }
    
    private func removeHighlight(_ highlight: BibleHighlight) {
        if let id = highlight.id {
            UserInfoRepository.shared.deleteHighlight(id: id)
            alertMessage = "Highlight removed successfully!"
            
            // Reload highlights
            existingHighlights = UserInfoRepository.shared.getHighlights(
                seriesName: book.seriesName,
                bookId: book.id,
                chapter: currentChapter
            )
            
            showAlert = true
        }
    }
    
    // MARK: - Context Menu Actions
    
    private func bookmarkVerses(_ range: ClosedRange<Int>) {
        let bookmark = BibleBookmark(
            seriesName: book.seriesName,
            bookId: book.id,
            chapter: currentChapter,
            verseStart: range.lowerBound,
            verseEnd: range.upperBound
        )
        
        UserInfoRepository.shared.saveBookmark(bookmark)
        alertMessage = "Verses bookmarked successfully!"
        showAlert = true
    }
    
    private func copyVerses(_ range: ClosedRange<Int>) {
        let selectedVerseTexts = verses
            .filter { range.contains($0.verse) }
            .map { "\($0.verse). \($0.text)" }
            .joined(separator: "\n")
        
        UIPasteboard.general.string = "\(book.name) \(currentChapter)\n\n\(selectedVerseTexts)"
        alertMessage = "Verses copied to clipboard!"
        showAlert = true
    }
    
    private func shareVerses(_ range: ClosedRange<Int>) {
        let selectedVerseTexts = verses
            .filter { range.contains($0.verse) }
            .map { "\($0.verse). \($0.text)" }
            .joined(separator: "\n")
        
        let shareText = "\(book.name) \(currentChapter)\n\n\(selectedVerseTexts)"
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    // MARK: - Navigation Actions
    
    private func previousChapter() {
        guard currentChapter > 1 else { return }
        currentChapter -= 1
    }
    
    private func nextChapter() {
        guard currentChapter < maxChapterCount else { return }
        currentChapter += 1
    }
    
    private func toggleBookmark() {
        // TODO: Toggle bookmark for this chapter
        print("Bookmark toggled")
    }
    
    private func changeLanguage() {
        // TODO: Implement language change
        print("Change language tapped")
    }
    
    private func showChapterPicker() {
        // TODO: Implement chapter picker
        print("Chapter picker tapped")
    }
    
    private func bookmarkPage() {
        let bookmark = BibleBookmark(
            seriesName: book.seriesName,
            bookId: book.id,
            chapter: currentChapter,
            verseStart: nil,
            verseEnd: nil
        )
        
        UserInfoRepository.shared.saveBookmark(bookmark)
        alertMessage = "Chapter bookmarked successfully!"
        showAlert = true
    }
}

// MARK: - Supporting Views

struct VerseRow: View {
    let verse: BibleVerse
    let highlight: BibleHighlight?
    let isSelected: Bool
    let theme: AppTheme
    let fontSize: FontSize
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 8) {
                // Verse number
                Text("\(verse.verse)")
                    .font(.scaledCaption(fontSize))
                    .foregroundColor(theme.accent)
                    .frame(width: 30, alignment: .trailing)
                
                // Verse text
                Text(verse.text)
                    .font(.scaledBody(fontSize))
                    .foregroundColor(theme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(
                Group {
                    if let highlight = highlight {
                        highlightColor(for: highlight.highlightColor)
                            .opacity(0.3)
                    } else if isSelected {
                        theme.accent.opacity(0.2)
                    } else {
                        Color.clear
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func highlightColor(for colorName: String) -> Color {
        switch colorName {
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "red": return .red
        case "purple": return .purple
        case "orange": return .orange
        default: return .yellow
        }
    }
}

struct ContextMenuView: View {
    let onHighlight: () -> Void
    let onAddNote: () -> Void
    let onBookmark: () -> Void
    let onCopy: () -> Void
    let onShare: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 0) {
            ContextMenuButton(icon: "highlighter", text: "Highlight", action: onHighlight)
            Divider().background(themeManager.currentTheme.divider)
            ContextMenuButton(icon: "note.text", text: "Add Note", action: onAddNote)
            Divider().background(themeManager.currentTheme.divider)
            ContextMenuButton(icon: "bookmark", text: "Bookmark", action: onBookmark)
            Divider().background(themeManager.currentTheme.divider)
            ContextMenuButton(icon: "doc.on.doc", text: "Copy", action: onCopy)
            Divider().background(themeManager.currentTheme.divider)
            ContextMenuButton(icon: "square.and.arrow.up", text: "Share", action: onShare)
        }
        .frame(width: 250)
        .background(themeManager.currentTheme.cardBackground)
        .cornerRadius(12)
        .shadow(color: themeManager.currentTheme.shadow, radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
        )
    }
}

struct ContextMenuButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(themeManager.currentTheme.accent)
                    .frame(width: 30)
                
                Text(text)
                    .font(.scaledBody(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.primaryText)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(themeManager.currentTheme.cardBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HighlightNoteSheet: View {
    let book: BibleBook
    let chapter: Int
    let verseRange: ClosedRange<Int>
    let verses: [BibleVerse]
    let existingHighlight: BibleHighlight?
    let focusNote: Bool
    let onSave: (BibleHighlight) -> Void
    let onRemove: () -> Void
    let onCancel: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedColor: String
    @State private var noteText: String
    @FocusState private var isNoteFocused: Bool
    
    init(book: BibleBook, chapter: Int, verseRange: ClosedRange<Int>, verses: [BibleVerse], existingHighlight: BibleHighlight?, focusNote: Bool, onSave: @escaping (BibleHighlight) -> Void, onRemove: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.book = book
        self.chapter = chapter
        self.verseRange = verseRange
        self.verses = verses
        self.existingHighlight = existingHighlight
        self.focusNote = focusNote
        self.onSave = onSave
        self.onRemove = onRemove
        self.onCancel = onCancel
        
        _selectedColor = State(initialValue: existingHighlight?.highlightColor ?? "yellow")
        _noteText = State(initialValue: existingHighlight?.additionalNotes ?? "")
    }
    
    private let colors = ["yellow", "green", "blue", "red", "purple", "orange"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Verse display
                    verseDisplay
                    
                    // Color picker
                    colorPicker
                    
                    // Note input
                    noteInput
                    
                    // Remove button (if editing)
                    if existingHighlight != nil {
                        removeButton
                    }
                }
                .padding()
            }
            .background(themeManager.currentTheme.background)
            .navigationTitle("Add Highlight / Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                        .foregroundColor(themeManager.currentTheme.accent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: handleSave)
                        .foregroundColor(themeManager.currentTheme.accent)
                }
            }
            .onAppear {
                if focusNote {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isNoteFocused = true
                    }
                }
            }
        }
    }
    
    private var verseDisplay: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Verse")
                .font(.scaledHeadline(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.primaryText)
            
            let selectedVerses = verses.filter { verseRange.contains($0.verse) }
            let verseText = selectedVerses.map { "\($0.verse). \($0.text)" }.joined(separator: " ")
            
            Text(verseText)
                .font(.scaledBody(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.primaryText)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(themeManager.currentTheme.cardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
                )
        }
    }
    
    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Highlight Color")
                .font(.scaledHeadline(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.primaryText)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                ForEach(colors, id: \.self) { colorName in
                    Button(action: {
                        selectedColor = colorName
                    }) {
                        Circle()
                            .fill(colorForName(colorName))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == colorName ? themeManager.currentTheme.accent : Color.clear, lineWidth: 3)
                            )
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(themeManager.currentTheme.cardBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
            )
        }
    }
    
    private var noteInput: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Note")
                .font(.scaledHeadline(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.primaryText)
                .padding(.horizontal)
            
            TextEditor(text: $noteText)
                .font(.scaledBody(themeManager.fontSize))
                .foregroundColor(themeManager.currentTheme.primaryText)
                .frame(minHeight: 120)
                .padding(8)
                .background(themeManager.currentTheme.cardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
                )
                .focused($isNoteFocused)
            
            if noteText.isEmpty {
                Text("User input text")
                    .font(.scaledBody(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.secondaryText)
                    .padding(.horizontal)
            }
        }
    }
    
    private var removeButton: some View {
        Button(action: onRemove) {
            Text("Remove Highlight/Notes")
                .font(.scaledBody(themeManager.fontSize))
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(themeManager.currentTheme.cardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red, lineWidth: 1)
                )
        }
    }
    
    private func colorForName(_ name: String) -> Color {
        switch name {
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "red": return .red
        case "purple": return .purple
        case "orange": return .orange
        default: return .yellow
        }
    }
    
    private func handleSave() {
        let highlight = BibleHighlight(
            id: existingHighlight?.id,
            seriesName: book.seriesName,
            bookId: book.id,
            chapter: chapter,
            verseStart: verseRange.lowerBound,
            verseEnd: verseRange.upperBound,
            highlightColor: selectedColor,
            additionalNotes: noteText.isEmpty ? nil : noteText
        )
        
        onSave(highlight)
    }
}

#Preview {
    NavigationStack {
        ChapterSelectedView(
            book: BibleBook(id: 1, name: "Book of Genesis", description: nil, ord: 1, database: .oldTestament),
            chapter: 1
        )
        .environmentObject(ThemeManager.shared)
    }
}
