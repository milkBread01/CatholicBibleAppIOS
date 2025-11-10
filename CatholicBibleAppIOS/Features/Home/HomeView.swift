
// Features/Home/HomeView.swift
import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        AppScaffold {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    SectionHeader(text: "Daily Quote")
                    Card {
                        if let q = vm.quote {
                            Text("“\(q.text)”").font(AppFont.body()).padding(.bottom, 4)
                            Text(q.source).font(AppFont.caption()).foregroundColor(AppColor.subtle)
                        } else { ProgressView() }
                    }

                    SectionHeader(text: "Seasonal Card")
                    Card {
                        Text("Feast day / Lent / Advent card…")
                            .font(AppFont.body())
                    }

                    SectionHeader(text: "Today's Invitation")
                    HStack(spacing: Spacing.m) {
                        Button("Daily Reading Book & Chapter") { /* navigate */ }
                            .buttonStyle(.borderedProminent)
                        Button("Today's Rosary") { /* navigate */ }
                            .buttonStyle(.bordered)
                    }
                    .padding(.horizontal, Spacing.m)

                    SectionHeader(text: "Mass Schedule")
                    Card("This Week's Readings") {
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            ForEach(vm.weeklyReadingTitles, id: \.self) { t in
                                Text(t).font(AppFont.body())
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    SectionHeader(text: "Find Your Parish")
                    Button("[Find Nearby Parishes]") { /* push ParishSearch */ }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal, Spacing.m)

                    Card("AD") { Rectangle().frame(height: 80).opacity(0.12) }
                        .padding(.bottom, Spacing.xl)
                }
                .padding(.top, Spacing.m)
                .padding(.horizontal, Spacing.m)
            }
            .task { await vm.load() }
        }
    }
}
