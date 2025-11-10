


// Features/Home/HomeViewModel.swift
import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var quote: QuoteRow?
    @Published var weeklyReadingTitles: [String] = []  // stub for now
    @Published var isLoading = false

    private let quotes = QuoteRepository()
    private let bible  = BibleRepository()

    func load() async {
        isLoading = true; defer { isLoading = false }
        do {
            quote = try quotes.quoteFor(day: Date())

            // Example: collect next 7 “Psalms of the Day” titles (stub)
            weeklyReadingTitles = (1...7).map { "Reading \($0): Isaiah …" }
        } catch {
            quote = QuoteRow(id: 0, text: "Welcome.", source: "App")
        }
    }
}
