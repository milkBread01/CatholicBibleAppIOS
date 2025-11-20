// ============================================
// File: Features/Bible/ViewModels/BibleViewModel.swift
// ============================================
import SwiftUI
import Combine

class BibleViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var allBooks: [BibleBook] = []
    @Published var bookSections: [BookSection] = []
    @Published var selectedTestament: Testament?
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var searchResults: [SearchResult] = []
    @Published var showingSearch = false
    
    // Navigation selection (Option A can work without this if using NavigationLink(value:),
    // but we keep it in case you want to trigger navigation programmatically later)
    @Published var selectedBook: BibleBook?
    
    // MARK: - Services
    private let repository = BibleRepository.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadBooks()
        setupSearch()
    }
    
    // MARK: - Data Loading
    func loadBooks() {
        isLoading = true
        
        Task {
            let books = await repository.getAllBooks()
            
            await MainActor.run {
                self.allBooks = books
                self.organizeBooksIntoSections()
                self.isLoading = false
            }
        }
    }
    
    private func organizeBooksIntoSections() {
        bookSections = [
            BookSection(
                testament: .oldTestament,
                books: allBooks.filter { $0.testament == .oldTestament }
            ),
            BookSection(
                testament: .deuterocanonical,
                books: allBooks.filter { $0.testament == .deuterocanonical }
            ),
            BookSection(
                testament: .newTestament,
                books: allBooks.filter { $0.testament == .newTestament }
            )
        ]
    }
    
    // MARK: - Search
    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) {
        guard query.count >= 3 else {
            searchResults = []
            return
        }
        
        Task {
            let tupleResults = await repository.searchVerses(query: query) // [(BibleVerse, BibleBook)]
            let mapped: [SearchResult] = tupleResults.map { verse, book in
                SearchResult(verse: verse, book: book)
            }
            
            await MainActor.run {
                self.searchResults = mapped
            }
        }
    }
    
    // MARK: - Actions
    func selectTestament(_ testament: Testament) {
        selectedTestament = testament
    }
    
    func toggleSearch() {
        showingSearch.toggle()
        if !showingSearch {
            searchText = ""
            searchResults = []
        }
    }
    
    func bookTapped(_ book: BibleBook) {
        print("📖 Book tapped: \(book.name)")
        // If you were not using NavigationLink(value:) you could set:
        // self.selectedBook = book
        // and drive a hidden NavigationLink in the view.
    }
    
    func searchTheBible() {
        showingSearch = true
    }
    
    func readTheWord() {
        // Navigate to daily reading
        print("📖 Read the Word tapped")
    }
    
    func viewBookmarks() {
        print("🔖 Bookmarks tapped")
    }
    
    func viewHighlights() {
        print("✨ Highlights tapped")
    }
}

