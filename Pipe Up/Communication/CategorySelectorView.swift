//
//  CategorySelectorView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/11/24.
//

import SwiftUI

struct CategorySelectorView: View {
    @EnvironmentObject var vm: ViewModel
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.displayOrder, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "category == %@", NSNull())) var recentPhrases: FetchedResults<SavedPhrase>
    
    @Binding var selectedCategory: PhraseCategory?
    
    let rows = [GridItem(.adaptive(minimum: 150), spacing: 5)]
    
    @AppStorage("lastSelectedCategory") var lastSelectedCategory: String = "Recents"
    
    var body: some View {
        ScrollViewReader { value in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows, spacing: 5) {
                    if !recentPhrases.isEmpty {
                        categoryButton(category: nil, text: "Recents", value: value)
                            .id(0)
                            .transition(.opacity.animation(.easeInOut))
                    }
                    
                    ForEach(categories) { category in
                        categoryButton(category: category, text: category.title, value: value)
                    }
                }
                .animation(.easeInOut, value: recentPhrases.count) // Lets the Recents category selector animate in smoothly
                .padding(.horizontal)
            }
            .onChange(of: selectedCategory) { category in
                withAnimation {
//                        if category == nil {
//                            value.scrollTo(0, anchor: .trailing)
//                        } else {
//                            value.scrollTo(category?.id, anchor: .trailing)
//                        }
                    
                    scrollToSelectedCategory(category: category, value: value)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxHeight: 70)
        .onChange(of: Array(recentPhrases)) { _ in
            // Selects the first category that contains phrases, when the last phrase is removed from Recents
            if recentPhrases.isEmpty {
                selectedCategory = categories.first(where: { $0.phrases?.count != 0 })
            }
        }
        .onAppear {
            // Selects the first category that contains phrases, if Recents was the last selected category and is now empty; added primarily for when phrases are syncing via iCloud
            if recentPhrases.isEmpty && lastSelectedCategory == "Recents" {
                selectedCategory = categories.first(where: { $0.phrases?.count != 0 })
            }
        }
    }
    
    // Category selection button
    private func categoryButton(category: PhraseCategory?, text: String, value: ScrollViewProxy) -> some View {
        Button {
            withAnimation {
                selectedCategory = category
//                scrollToSelectedCategory(category: category, value: value)
            }
        } label: {
            HStack {
                Image(systemName: category?.symbolName ?? "clock.arrow.circlepath")
                    .foregroundStyle(selectedCategory == category ? Color(.defaultAccent) : Color.secondary)
                
                if selectedCategory == category {
                    Text(text)
                }
            }
            .font(.headline)
            .foregroundStyle(selectedCategory == category ? Color.primary : Color.secondary)
            .padding()
            .frame(height: 50)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
            .drawingGroup()
                
        }
        .accessibilityLabel(text)
        .padding(.vertical)
    }
    
    func scrollToSelectedCategory(category: PhraseCategory?, value: ScrollViewProxy) {
        value.scrollTo(category?.id, anchor: .center)
    }
}

#Preview {
    CategorySelectorView(selectedCategory: .constant(nil))
        .environmentObject(ViewModel())
}
