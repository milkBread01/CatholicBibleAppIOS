// ============================================
// File: Features/Bible/Views/BibleSearchView.swift
// ============================================
import SwiftUI

struct BibleSearchView: View {
    @ObservedObject var viewModel: BibleViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(themeManager.currentTheme.secondaryText)
                        
                        TextField("Search verses...", text: $viewModel.searchText)
                            .font(.scaledBody(themeManager.fontSize))
                            .foregroundColor(themeManager.currentTheme.primaryText)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        if !viewModel.searchText.isEmpty {
                            Button(action: { viewModel.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(themeManager.currentTheme.secondaryText)
                            }
                        }
                    }
                    .padding()
                    .background(themeManager.currentTheme.secondaryBackground)
                    
                    // Results
                    if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(themeManager.currentTheme.secondaryText)
                            Text("No results found")
                                .font(.scaledHeadline(themeManager.fontSize))
                                .foregroundColor(themeManager.currentTheme.secondaryText)
                            Spacer()
                        }
                    } else if !viewModel.searchResults.isEmpty {
                        List {
                            ForEach(viewModel.searchResults) { result in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("\(result.book.name) \(result.verse.chapter):\(result.verse.verse)")
                                        .font(.scaledCaption(themeManager.fontSize))
                                        .foregroundColor(themeManager.currentTheme.accent)
                                    
                                    Text(result.verse.text)
                                        .font(.scaledBody(themeManager.fontSize))
                                        .foregroundColor(themeManager.currentTheme.primaryText)
                                }
                                .padding(.vertical, 4)
                                .listRowBackground(themeManager.currentTheme.background)
                            }
                        }
                        .listStyle(.plain)
                    } else {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "book.fill")
                                .font(.system(size: 48))
                                .foregroundColor(themeManager.currentTheme.secondaryText)
                            Text("Search the Bible")
                                .font(.scaledHeadline(themeManager.fontSize))
                                .foregroundColor(themeManager.currentTheme.primaryText)
                            Text("Enter at least 3 characters to search")
                                .font(.scaledCaption(themeManager.fontSize))
                                .foregroundColor(themeManager.currentTheme.secondaryText)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Search Bible")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentTheme.accent)
                }
            }
        }
    }
}

// ============================================
// File: Preview
// ============================================
#Preview {
    BibleDashboardView()
        .environmentObject(ThemeManager.shared)
}
