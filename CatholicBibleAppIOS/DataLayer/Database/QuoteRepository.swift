// DataLayer/Database/QuoteRepository.swift
import Foundation

/// Replace this stub with a GRDB-backed repository later.
public struct QuoteRepository {
    // Example in-memory quotes rotation.
    private let quotes: [QuoteRow] = [
        .init(id: 1, text: "The Eucharist is the source and summit of the Christian life.", source: "St. Thomas Aquinas"),
        .init(id: 2, text: "Pray, hope, and don’t worry.", source: "Padre Pio"),
        .init(id: 3, text: "Late have I loved you, Beauty ever ancient, ever new!", source: "St. Augustine"),
    ]

    public init() {}

    /// Deterministic “quote of the day”.
    public func quoteFor(day: Date) throws -> QuoteRow {
        let dayIndex = Int(Calendar.current.ordinality(of: .day, in: .year, for: day) ?? 1)
        guard !quotes.isEmpty else { throw NSError(domain: "QuoteRepository", code: 1) }
        return quotes[(dayIndex - 1) % quotes.count]
    }
}
