// ============================================
// File: DataLayer/Database/BibleRepository.swift
// ============================================
import Foundation
import SQLite

class BibleRepository {
    static let shared = BibleRepository()
    private var oldTestamentDB: Connection?
    private var newTestamentDB: Connection?
    
    // Table definitions
    private let booksTable = Table("bible_books")
    private let versesTable = Table("bible_verses")
    private let commentsTable = Table("bible_comments")
    
    // Column definitions
    private let id = Expression<Int>("id")
    private let name = Expression<String>("name")
    private let description = Expression<String?>("description")
    private let ord = Expression<Int>("ord")
    private let bookId = Expression<Int>("book_id")
    private let chapter = Expression<Int>("chapter")
    private let verse = Expression<Int>("verse")
    private let text = Expression<String>("text")
    private let comment = Expression<String>("comment")
    
    init() {
        connectDatabases()
    }
    
    private func connectDatabases() {
        // Connect to Old Testament database
        do {
            if let path = Bundle.main.path(forResource: "drv_old_testament", ofType: "db") {
                oldTestamentDB = try Connection(path, readonly: true)
                print("✅ Old Testament database connected successfully at: \(path)")
                
                // Verify connection by counting books
                if let db = oldTestamentDB {
                    let count = try db.scalar(booksTable.count)
                    print("📚 Old Testament books in DB: \(count)")
                }
            } else {
                print("❌ Old Testament database file not found")
            }
        } catch {
            print("❌ Old Testament database connection error: \(error)")
        }
        
        // Connect to New Testament database
        do {
            if let path = Bundle.main.path(forResource: "drv_new_testament", ofType: "db") {
                newTestamentDB = try Connection(path, readonly: true)
                print("✅ New Testament database connected successfully at: \(path)")
                
                // Verify connection by counting books
                if let db = newTestamentDB {
                    let count = try db.scalar(booksTable.count)
                    print("📚 New Testament books in DB: \(count)")
                }
            } else {
                print("❌ New Testament database file not found")
            }
        } catch {
            print("❌ New Testament database connection error: \(error)")
        }
    }
    
    // MARK: - Fetch Books
    func getAllBooks() async -> [BibleBook] {
        var allBooks: [BibleBook] = []
        
        // Get Old Testament books
        if let db = oldTestamentDB {
            do {
                let query = booksTable.order(ord)
                
                for row in try db.prepare(query) {
                    let bookName = try row.get(name)
                    
                    // Skip Esther if it appears (we only want the 7 deuterocanonical books)
                    if bookName.lowercased().contains("esther") {
                        continue
                    }
                    
                    allBooks.append(BibleBook(
                        id: try row.get(id),
                        name: bookName,
                        description: try row.get(description),
                        ord: try row.get(ord),
                        database: .oldTestament
                    ))
                }
                print("📖 Loaded \(allBooks.count) books from Old Testament DB")
            } catch {
                print("❌ Error fetching Old Testament books: \(error)")
            }
        }
        
        // Get New Testament books
        if let db = newTestamentDB {
            do {
                let query = booksTable.order(ord)
                let ntStartCount = allBooks.count
                
                for row in try db.prepare(query) {
                    allBooks.append(BibleBook(
                        id: try row.get(id),
                        name: try row.get(name),
                        description: try row.get(description),
                        ord: try row.get(ord),
                        database: .newTestament
                    ))
                }
                print("📖 Loaded \(allBooks.count - ntStartCount) books from New Testament DB")
            } catch {
                print("❌ Error fetching New Testament books: \(error)")
            }
        }
        
        return allBooks
    }
    
    func getBooksByTestament(_ testament: Testament) async -> [BibleBook] {
        let allBooks = await getAllBooks()
        
        switch testament {
        case .oldTestament:
            return allBooks.filter {
                $0.testament == .oldTestament && $0.database == .oldTestament
            }
        case .deuterocanonical:
            return allBooks.filter {
                DeuterocanonicalBooks.isDeuterocanonical($0.name)
            }
        case .newTestament:
            return allBooks.filter {
                $0.database == .newTestament
            }
        }
    }
    
    // MARK: - Fetch Verses
    func getChapter(book: BibleBook, chapter: Int) async -> [BibleVerse] {
        print("📖 Getting verses for: \(book.name), Chapter: \(chapter), Book ID: \(book.id), Database: \(book.database)")
        
        // Select correct database based on book's source
        let db = book.database == .oldTestament ? oldTestamentDB : newTestamentDB
        guard let db = db else {
            print("❌ Database not available for \(book.database)")
            return []
        }
        
        do {
            let query = versesTable
                .filter(self.bookId == book.id && self.chapter == chapter)
                .order(verse)
            
            var verses: [BibleVerse] = []
            
            for row in try db.prepare(query) {
                verses.append(BibleVerse(
                    id: try row.get(id),
                    bookId: try row.get(self.bookId),
                    chapter: try row.get(self.chapter),
                    verse: try row.get(self.verse),
                    text: try row.get(text)
                ))
            }
            
            print("✅ Found \(verses.count) verses")
            return verses
        } catch {
            print("❌ Error fetching verses: \(error)")
            return []
        }
    }
    
    // MARK: - Fetch Comments
    func getComments(book: BibleBook, chapter: Int) async -> [BibleComment] {
        print("📝 Getting comments for: \(book.name), Chapter: \(chapter), Book ID: \(book.id), Database: \(book.database)")
        
        // Select correct database based on book's source
        let db = book.database == .oldTestament ? oldTestamentDB : newTestamentDB
        guard let db = db else {
            print("❌ Database not available for \(book.database)")
            return []
        }
        
        do {
            let query = commentsTable
                .filter(self.bookId == book.id && self.chapter == chapter)
                .order(verse)
            
            var comments: [BibleComment] = []
            
            for row in try db.prepare(query) {
                comments.append(BibleComment(
                    id: try row.get(id),
                    bookId: try row.get(self.bookId),
                    chapter: try row.get(self.chapter),
                    verse: try row.get(self.verse),
                    comment: try row.get(comment)
                ))
            }
            
            print("✅ Found \(comments.count) comments")
            return comments
        } catch {
            print("❌ Error fetching comments: \(error)")
            return []
        }
    }
    
    func getChapterCount(book: BibleBook) async -> Int {
        print("📖 Getting chapter count for: \(book.name)")
        print("   Book ID: \(book.id)")
        print("   Database: \(book.database)")
        
        let db = book.database == .oldTestament ? oldTestamentDB : newTestamentDB
        
        guard let db = db else {
            print("❌ Database not available")
            return 0
        }
        
        do {
            // First, let's check if there are ANY verses for this book_id
            let totalVersesQuery = versesTable.filter(self.bookId == book.id)
            let totalVerses = try db.scalar(totalVersesQuery.count)
            print("   Total verses found for book_id \(book.id): \(totalVerses)")
            
            // If no verses at all, something is wrong
            if totalVerses == 0 {
                print("⚠️  No verses found for this book_id.")
                return 0
            }
            
            // Get distinct chapter numbers for this book
            // Use a Set to automatically handle distinct values
            let query = versesTable.filter(self.bookId == book.id)
            
            var chapterSet = Set<Int>()
            for row in try db.prepare(query) {
                let chapterNum = try row.get(chapter)
                chapterSet.insert(chapterNum)
            }
            
            let chapters = Array(chapterSet).sorted()
            print("✅ Found \(chapters.count) chapters: \(chapters.prefix(10))...")
            
            return chapters.count
        } catch {
            print("❌ Error getting chapter count: \(error)")
            return 0
        }
    }
    
    // MARK: - Search
    func searchVerses(query: String) async -> [(BibleVerse, BibleBook)] {
        guard query.count >= 3 else { return [] }
        
        var results: [(BibleVerse, BibleBook)] = []
        let allBooks = await getAllBooks()
        
        // Search Old Testament
        if let db = oldTestamentDB {
            do {
                let searchQuery = versesTable
                    .filter(text.like("%\(query)%"))
                    .limit(25)
                
                for row in try db.prepare(searchQuery) {
                    let verse = BibleVerse(
                        id: try row.get(id),
                        bookId: try row.get(bookId),
                        chapter: try row.get(chapter),
                        verse: try row.get(verse),
                        text: try row.get(text)
                    )
                    
                    if let book = allBooks.first(where: { $0.id == verse.bookId && $0.database == .oldTestament }) {
                        results.append((verse, book))
                    }
                }
            } catch {
                print("❌ Error searching Old Testament: \(error)")
            }
        }
        
        // Search New Testament
        if let db = newTestamentDB {
            do {
                let searchQuery = versesTable
                    .filter(text.like("%\(query)%"))
                    .limit(25)
                
                for row in try db.prepare(searchQuery) {
                    let verse = BibleVerse(
                        id: try row.get(id),
                        bookId: try row.get(bookId),
                        chapter: try row.get(chapter),
                        verse: try row.get(verse),
                        text: try row.get(text)
                    )
                    
                    if let book = allBooks.first(where: { $0.id == verse.bookId && $0.database == .newTestament }) {
                        results.append((verse, book))
                    }
                }
            } catch {
                print("❌ Error searching New Testament: \(error)")
            }
        }
        
        return Array(results.prefix(50))
    }
}

