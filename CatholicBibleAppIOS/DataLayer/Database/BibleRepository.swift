// DataLayer/Database/BibleRepository.swift
import Foundation

/// Replace with GRDB queries (books, chapters, verses) later.
public struct BibleRepository {
    public init() {}

    public func books() throws -> [String] {
        ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy"]
    }

    public func chapters(in book: String) throws -> [Int] {
        // Simple placeholder: 50 chapters for Genesis, else 20.
        book == "Genesis" ? Array(1...50) : Array(1...20)
    }

    public func chapter(book: String, chapter: Int) throws -> [VerseRow] {
        // Minimal 3-verse sample
        return [
            VerseRow(id: 1, book: book, chapter: chapter, verse: 1, text: "In the beginning…"),
            VerseRow(id: 2, book: book, chapter: chapter, verse: 2, text: "And the earth was void…"),
            VerseRow(id: 3, book: book, chapter: chapter, verse: 3, text: "And God said, Let there be light."),
        ]
    }
}
