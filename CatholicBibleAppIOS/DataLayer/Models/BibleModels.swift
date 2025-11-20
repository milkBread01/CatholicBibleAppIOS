// ============================================
// File: DataLayer/Models/BibleModels.swift
// ============================================
import Foundation

struct BibleBook: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let ord: Int
    let database: DatabaseSource  // Track which database this book is from
    
    var testament: Testament {
        // First, if the book came from the New Testament database, it's New Testament.
        if database == .newTestament {
            return .newTestament
        }
        // For books from the Old Testament database, check if they are deuterocanonical by name.
        if DeuterocanonicalBooks.isDeuterocanonical(name) {
            return .deuterocanonical
        }
        // Otherwise, treat as Old Testament.
        return .oldTestament
    }
}

enum DatabaseSource: String, Codable {
    case oldTestament
    case newTestament
}

// The 7 Deuterocanonical Books
enum DeuterocanonicalBooks: String, CaseIterable {
    case tobit = "The Book of Tobias"
    case judith = "The Book of Judith"
    case wisdom = "Book of Wisdom"
    case sirach = "Ecclesiasticus"
    case baruch = "Prophecy of Baruch"
    case maccabees1 = "The First Book of Machabees"
    case maccabees2 = "The Second Book of Machabees"
    
    static func isDeuterocanonical(_ bookName: String) -> Bool {
        let normalized = normalize(bookName)
        return allCases.contains {
            let raw = normalize($0.rawValue)
            return raw == normalized || normalized.contains(raw) || raw.contains(normalized)
        }
    }
    
    private static func normalize(_ s: String) -> String {
        s.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .replacingOccurrences(of: "’", with: "'")
            .replacingOccurrences(of: "the ", with: "")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct BibleVerse: Identifiable, Codable {
    let id: Int
    let bookId: Int
    let chapter: Int
    let verse: Int
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case id, chapter, verse, text
        case bookId = "book_id"
    }
}

struct BibleComment: Identifiable, Codable {
    let id: Int
    let bookId: Int
    let chapter: Int
    let verse: Int
    let comment: String
    
    enum CodingKeys: String, CodingKey {
        case id, chapter, verse, comment
        case bookId = "book_id"
    }
}

enum Testament: String, CaseIterable {
    case oldTestament = "Old Testament"
    case deuterocanonical = "Deuterocanonical"
    case newTestament = "New Testament"
    
    var displayName: String {
        return self.rawValue
    }
}

struct BookSection: Identifiable {
    let id = UUID()
    let testament: Testament
    let books: [BibleBook]
}

// Helper struct for search results
struct SearchResult: Identifiable {
    let id = UUID()
    let verse: BibleVerse
    let book: BibleBook
}

// ============================================
// File: DataLayer/Models/BibleModels+Extensions.swift
// ============================================
import Foundation

extension BibleBook {
    /// Returns the series name for this book's database
    /// Used for storing highlights and bookmarks with proper database reference
    var seriesName: String {
        switch database {
        case .oldTestament:
            return "drv_old_testament"
        case .newTestament:
            return "drv_new_testament"
        }
    }
}
