// ============================================
// File: DataLayer/Database/UserInfoRepository.swift
// ============================================
import Foundation
import SQLite

class UserInfoRepository {
    static let shared = UserInfoRepository()
    private var db: Connection?
    
    // Table definitions
    private let userPreferencesTable = Table("user_preferences")
    private let highlightsTable = Table("bible_highlights")
    private let bookmarksTable = Table("bible_bookmarks")
    
    // user_preferences columns
    private let prefId = Expression<Int>("id")
    private let theme = Expression<String>("theme")
    private let textSize = Expression<String>("text_size")
    private let shareLocation = Expression<Int>("share_location")
    
    // bible_highlights columns
    private let highlightId = Expression<Int>("id")
    private let seriesName = Expression<String>("series_name")
    private let bookId = Expression<Int>("book_id")
    private let chapter = Expression<Int>("chapter")
    private let verseStart = Expression<Int>("verse_start")
    private let verseEnd = Expression<Int>("verse_end")
    private let highlightColor = Expression<String>("highlight_color")
    private let additionalNotes = Expression<String?>("additional_notes")
    
    // bible_bookmarks columns
    private let bookmarkId = Expression<Int>("id")
    private let bookmarkSeriesName = Expression<String>("series_name")
    private let bookmarkBookId = Expression<Int>("book_id")
    private let bookmarkChapter = Expression<Int>("chapter")
    private let bookmarkVerseStart = Expression<Int?>("verse_start")
    private let bookmarkVerseEnd = Expression<Int?>("verse_end")
    private let bookmarkNote = Expression<String?>("note")
    
    // Timestamp columns (used in multiple tables)
    private let dateAdded = Expression<String>("date_added")
    private let dateModified = Expression<String>("date_modified")
    
    init() {
        connectDatabase()
    }
    
    private func connectDatabase() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dbPath = documentsURL.appendingPathComponent("user_info.db")
        
        do {
            db = try Connection(dbPath.path)
            print("✅ User info database connected at: \(dbPath.path)")
            
            // Create tables if they don't exist
            try createTablesIfNeeded()
            
            // Initialize default preferences if needed
            try initializeDefaultPreferences()
        } catch {
            print("❌ Error connecting to user_info.db: \(error)")
        }
    }
    
    private func createTablesIfNeeded() throws {
        guard let db = db else { return }
        
        // Create user_preferences table
        try db.run(userPreferencesTable.create(ifNotExists: true) { t in
            t.column(prefId, primaryKey: true)
            t.column(theme, defaultValue: "light")
            t.column(textSize, defaultValue: "medium")
            t.column(shareLocation, defaultValue: 0)
            t.column(dateAdded, defaultValue: Expression<String>(literal: "datetime('now')"))
            t.column(dateModified, defaultValue: Expression<String>(literal: "datetime('now')"))
            
            // Lock to a single row
            t.check(prefId == 1)
            // Note: app-level validation will enforce allowed values.
        })
        
        // Create bible_highlights table
        try db.run(highlightsTable.create(ifNotExists: true) { t in
            t.column(highlightId, primaryKey: .autoincrement)
            t.column(seriesName)
            t.column(bookId)
            t.column(chapter)
            t.column(verseStart)
            t.column(verseEnd)
            t.column(highlightColor)
            t.column(additionalNotes)
            t.column(dateAdded, defaultValue: Expression<String>(literal: "datetime('now')"))
            t.column(dateModified, defaultValue: Expression<String>(literal: "datetime('now')"))
            
            // Keep only the range check here; color will be validated app-side
            t.check(verseStart <= verseEnd)
        })
        
        // Create bible_bookmarks table
        try db.run(bookmarksTable.create(ifNotExists: true) { t in
            t.column(bookmarkId, primaryKey: .autoincrement)
            t.column(bookmarkSeriesName)
            t.column(bookmarkBookId)
            t.column(bookmarkChapter)
            t.column(bookmarkVerseStart)
            t.column(bookmarkVerseEnd)
            t.column(bookmarkNote)
            t.column(dateAdded, defaultValue: Expression<String>(literal: "datetime('now')"))
            t.column(dateModified, defaultValue: Expression<String>(literal: "datetime('now')"))
        })
        
        print("✅ User info database tables created/verified")
    }
    
    private func initializeDefaultPreferences() throws {
        guard let db = db else { return }
        
        // Check if preferences row exists
        let count = try db.scalar(userPreferencesTable.count)
        
        if count == 0 {
            // Insert default preferences
            try db.run(userPreferencesTable.insert(
                prefId <- 1,
                theme <- "light",
                textSize <- "medium",
                shareLocation <- 0
            ))
            print("✅ Default user preferences initialized")
        }
    }
    
    // MARK: - App-level validation helpers
    
    private func isValidTheme(_ value: String) -> Bool {
        switch value {
        case "light", "dark", "sepia":
            return true
        default:
            return false
        }
    }
    
    private func isValidTextSize(_ value: String) -> Bool {
        switch value {
        case "small", "medium", "large":
            return true
        default:
            return false
        }
    }
    
    private func isValidShareLocation(_ value: Int) -> Bool {
        return value == 0 || value == 1
    }
    
    private func isValidHighlightColor(_ value: String) -> Bool {
        switch value {
        case "yellow", "green", "blue", "red", "purple", "orange":
            return true
        default:
            return false
        }
    }
    
    // MARK: - User Preferences
    
    func getUserPreferences() -> UserPreferences? {
        guard let db = db else { return nil }
        
        do {
            if let row = try db.pluck(userPreferencesTable) {
                return UserPreferences(
                    theme: try row.get(theme),
                    textSize: try row.get(textSize),
                    shareLocation: try row.get(shareLocation) == 1
                )
            }
        } catch {
            print("❌ Error fetching user preferences: \(error)")
        }
        
        return nil
    }
    
    func updateUserPreferences(_ prefs: UserPreferences) {
        guard let db = db else { return }
        
        // Validate inputs
        guard isValidTheme(prefs.theme) else {
            print("❌ Invalid theme: \(prefs.theme)")
            return
        }
        guard isValidTextSize(prefs.textSize) else {
            print("❌ Invalid text size: \(prefs.textSize)")
            return
        }
        let shareInt = prefs.shareLocation ? 1 : 0
        guard isValidShareLocation(shareInt) else {
            print("❌ Invalid shareLocation: \(shareInt)")
            return
        }
        
        do {
            let prefRow = userPreferencesTable.filter(prefId == 1)
            try db.run(prefRow.update(
                theme <- prefs.theme,
                textSize <- prefs.textSize,
                shareLocation <- shareInt,
                dateModified <- Expression<String>(literal: "datetime('now')")
            ))
            print("✅ User preferences updated")
        } catch {
            print("❌ Error updating user preferences: \(error)")
        }
    }
    
    // MARK: - Highlights
    
    func getHighlights(seriesName: String, bookId: Int, chapter: Int) -> [BibleHighlight] {
        guard let db = db else { return [] }
        
        do {
            let query = highlightsTable
                .filter(self.seriesName == seriesName && self.bookId == bookId && self.chapter == chapter)
                .order(verseStart)
            
            var highlights: [BibleHighlight] = []
            
            for row in try db.prepare(query) {
                highlights.append(BibleHighlight(
                    id: try row.get(highlightId),
                    seriesName: try row.get(self.seriesName),
                    bookId: try row.get(self.bookId),
                    chapter: try row.get(self.chapter),
                    verseStart: try row.get(self.verseStart),
                    verseEnd: try row.get(self.verseEnd),
                    highlightColor: try row.get(self.highlightColor),
                    additionalNotes: try row.get(self.additionalNotes)
                ))
            }
            
            print("✅ Found \(highlights.count) highlights")
            return highlights
        } catch {
            print("❌ Error fetching highlights: \(error)")
            return []
        }
    }
    
    func checkHighlightOverlap(seriesName: String, bookId: Int, chapter: Int, verseStart: Int, verseEnd: Int, excludingId: Int? = nil) -> Bool {
        guard let db = db else { return false }
        
        do {
            var query = highlightsTable
                .filter(self.seriesName == seriesName && self.bookId == bookId && self.chapter == chapter)
            
            // Exclude current highlight if editing
            if let excludingId = excludingId {
                query = query.filter(highlightId != excludingId)
            }
            
            // Check for overlaps: new range overlaps if:
            // (new_start <= existing_end) AND (new_end >= existing_start)
            for row in try db.prepare(query) {
                let existingStart = try row.get(self.verseStart)
                let existingEnd = try row.get(self.verseEnd)
                
                if verseStart <= existingEnd && verseEnd >= existingStart {
                    print("⚠️ Highlight overlap detected: new(\(verseStart)-\(verseEnd)) vs existing(\(existingStart)-\(existingEnd))")
                    return true
                }
            }
            
            return false
        } catch {
            print("❌ Error checking highlight overlap: \(error)")
            return false
        }
    }
    
    func saveHighlight(_ highlight: BibleHighlight) -> Bool {
        guard let db = db else { return false }
        
        // Validate highlight color
        guard isValidHighlightColor(highlight.highlightColor) else {
            print("❌ Invalid highlight color: \(highlight.highlightColor)")
            return false
        }
        
        // Check for overlap
        if checkHighlightOverlap(
            seriesName: highlight.seriesName,
            bookId: highlight.bookId,
            chapter: highlight.chapter,
            verseStart: highlight.verseStart,
            verseEnd: highlight.verseEnd,
            excludingId: highlight.id
        ) {
            print("❌ Cannot save highlight: overlaps with existing highlight")
            return false
        }
        
        do {
            if let id = highlight.id {
                // Update existing highlight
                let highlightRow = highlightsTable.filter(highlightId == id)
                try db.run(highlightRow.update(
                    verseStart <- highlight.verseStart,
                    verseEnd <- highlight.verseEnd,
                    highlightColor <- highlight.highlightColor,
                    additionalNotes <- highlight.additionalNotes,
                    dateModified <- Expression<String>(literal: "datetime('now')")
                ))
                print("✅ Highlight updated: ID \(id)")
            } else {
                // Insert new highlight
                try db.run(highlightsTable.insert(
                    seriesName <- highlight.seriesName,
                    bookId <- highlight.bookId,
                    chapter <- highlight.chapter,
                    verseStart <- highlight.verseStart,
                    verseEnd <- highlight.verseEnd,
                    highlightColor <- highlight.highlightColor,
                    additionalNotes <- highlight.additionalNotes
                ))
                print("✅ Highlight saved")
            }
            return true
        } catch {
            print("❌ Error saving highlight: \(error)")
            return false
        }
    }
    
    func deleteHighlight(id: Int) {
        guard let db = db else { return }
        
        do {
            let highlightRow = highlightsTable.filter(highlightId == id)
            try db.run(highlightRow.delete())
            print("✅ Highlight deleted: ID \(id)")
        } catch {
            print("❌ Error deleting highlight: \(error)")
        }
    }
    
    // MARK: - Bookmarks
    
    func getBookmarks(seriesName: String, bookId: Int, chapter: Int) -> [BibleBookmark] {
        guard let db = db else { return [] }
        
        do {
            let query = bookmarksTable
                .filter(bookmarkSeriesName == seriesName && bookmarkBookId == bookId && bookmarkChapter == chapter)
            
            var bookmarks: [BibleBookmark] = []
            
            for row in try db.prepare(query) {
                bookmarks.append(BibleBookmark(
                    id: try row.get(bookmarkId),
                    seriesName: try row.get(bookmarkSeriesName),
                    bookId: try row.get(bookmarkBookId),
                    chapter: try row.get(bookmarkChapter),
                    verseStart: try row.get(bookmarkVerseStart),
                    verseEnd: try row.get(bookmarkVerseEnd),
                    note: try row.get(bookmarkNote)
                ))
            }
            
            print("✅ Found \(bookmarks.count) bookmarks")
            return bookmarks
        } catch {
            print("❌ Error fetching bookmarks: \(error)")
            return []
        }
    }
    
    func getAllBookmarks() -> [BibleBookmark] {
        guard let db = db else { return [] }
        
        do {
            let query = bookmarksTable.order(dateAdded.desc)
            var bookmarks: [BibleBookmark] = []
            
            for row in try db.prepare(query) {
                bookmarks.append(BibleBookmark(
                    id: try row.get(bookmarkId),
                    seriesName: try row.get(bookmarkSeriesName),
                    bookId: try row.get(bookmarkBookId),
                    chapter: try row.get(bookmarkChapter),
                    verseStart: try row.get(bookmarkVerseStart),
                    verseEnd: try row.get(bookmarkVerseEnd),
                    note: try row.get(bookmarkNote)
                ))
            }
            
            print("✅ Found \(bookmarks.count) total bookmarks")
            return bookmarks
        } catch {
            print("❌ Error fetching all bookmarks: \(error)")
            return []
        }
    }
    
    func saveBookmark(_ bookmark: BibleBookmark) {
        guard let db = db else { return }
        
        // No special validation needed here beyond basic types; add if you later constrain notes etc.
        do {
            if let id = bookmark.id {
                // Update existing bookmark
                let bookmarkRow = bookmarksTable.filter(bookmarkId == id)
                try db.run(bookmarkRow.update(
                    bookmarkVerseStart <- bookmark.verseStart,
                    bookmarkVerseEnd <- bookmark.verseEnd,
                    bookmarkNote <- bookmark.note,
                    dateModified <- Expression<String>(literal: "datetime('now')")
                ))
                print("✅ Bookmark updated: ID \(id)")
            } else {
                // Insert new bookmark
                try db.run(bookmarksTable.insert(
                    bookmarkSeriesName <- bookmark.seriesName,
                    bookmarkBookId <- bookmark.bookId,
                    bookmarkChapter <- bookmark.chapter,
                    bookmarkVerseStart <- bookmark.verseStart,
                    bookmarkVerseEnd <- bookmark.verseEnd,
                    bookmarkNote <- bookmark.note
                ))
                print("✅ Bookmark saved")
            }
        } catch {
            print("❌ Error saving bookmark: \(error)")
        }
    }
    
    func deleteBookmark(id: Int) {
        guard let db = db else { return }
        
        do {
            let bookmarkRow = bookmarksTable.filter(bookmarkId == id)
            try db.run(bookmarkRow.delete())
            print("✅ Bookmark deleted: ID \(id)")
        } catch {
            print("❌ Error deleting bookmark: \(error)")
        }
    }
}

// MARK: - Data Models

struct UserPreferences {
    let theme: String
    let textSize: String
    let shareLocation: Bool
}

struct BibleHighlight: Identifiable {
    let id: Int?
    let seriesName: String
    let bookId: Int
    let chapter: Int
    let verseStart: Int
    let verseEnd: Int
    let highlightColor: String
    let additionalNotes: String?
    
    init(id: Int? = nil, seriesName: String, bookId: Int, chapter: Int, verseStart: Int, verseEnd: Int, highlightColor: String, additionalNotes: String? = nil) {
        self.id = id
        self.seriesName = seriesName
        self.bookId = bookId
        self.chapter = chapter
        self.verseStart = verseStart
        self.verseEnd = verseEnd
        self.highlightColor = highlightColor
        self.additionalNotes = additionalNotes
    }
}

struct BibleBookmark: Identifiable {
    let id: Int?
    let seriesName: String
    let bookId: Int
    let chapter: Int
    let verseStart: Int?
    let verseEnd: Int?
    let note: String?
    
    var isChapterBookmark: Bool {
        return verseStart == nil && verseEnd == nil
    }
    
    init(id: Int? = nil, seriesName: String, bookId: Int, chapter: Int, verseStart: Int? = nil, verseEnd: Int? = nil, note: String? = nil) {
        self.id = id
        self.seriesName = seriesName
        self.bookId = bookId
        self.chapter = chapter
        self.verseStart = verseStart
        self.verseEnd = verseEnd
        self.note = note
    }
}
