// ============================================
// File: Features/Bible/Views/BookSelectedView.swift
// ============================================
import SwiftUI

struct BookSelectedView: View {
    let book: BibleBook
    
    @EnvironmentObject var themeManager: ThemeManager
    @State private var chapterCount: Int = 0
    @State private var isLoading: Bool = true
    
    // 4 columns grid
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Select Chapter")
                    .font(.scaledHeadline(themeManager.fontSize))
                    .foregroundColor(themeManager.currentTheme.primaryText)
                    .padding(.horizontal)
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if chapterCount == 0 {
                    Text("No chapters found for this book.")
                        .font(.scaledBody(themeManager.fontSize))
                        .foregroundColor(themeManager.currentTheme.secondaryText)
                        .padding(.horizontal)
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(1...chapterCount, id: \.self) { chapter in
                            NavigationLink {
                                ChapterSelectedView(book: book, chapter: chapter)
                                    .environmentObject(themeManager)
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(themeManager.currentTheme.cardBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(themeManager.currentTheme.cardBorder, lineWidth: 1)
                                        )
                                    Text("\(chapter)")
                                        .font(.scaledBody(themeManager.fontSize))
                                        .foregroundColor(themeManager.currentTheme.primaryText)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                }
                                .frame(height: 48)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 12)
        }
        .background(themeManager.currentTheme.background.ignoresSafeArea())
        .navigationTitle(book.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadChapterCount()
        }
    }
    
    @MainActor
    private func setChapterCount(_ count: Int) {
        self.chapterCount = count
        self.isLoading = false
    }
    
    private func loadChapterCount() async {
        isLoading = true
        let count = await BibleRepository.shared.getChapterCount(book: book)
        await MainActor.run {
            setChapterCount(count)
        }
    }
}

#Preview {
    NavigationStack {
        BookSelectedView(book: BibleBook(id: 1, name: "Book of Genesis", description: nil, ord: 1, database: .oldTestament))
            .environmentObject(ThemeManager.shared)
    }
}

