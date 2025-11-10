// DataLayer/Database/Models.swift
import Foundation

// Minimal model for the Home screen's quote.
// Replace/expand when wiring to SQLite.
public struct QuoteRow: Identifiable, Equatable {
    public let id: Int
    public let text: String
    public let source: String
    public init(id: Int, text: String, source: String) {
        self.id = id; self.text = text; self.source = source
    }
}

// Optional: a minimal Bible verse row (use when you wire chapter views)
public struct VerseRow: Identifiable, Equatable {
    public let id: Int
    public let book: String
    public let chapter: Int
    public let verse: Int
    public let text: String
    public init(id: Int, book: String, chapter: Int, verse: Int, text: String) {
        self.id = id; self.book = book; self.chapter = chapter; self.verse = verse; self.text = text
    }
}
