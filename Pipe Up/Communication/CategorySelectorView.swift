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
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { value in
                LazyHGrid(rows: rows, spacing: 5) {
                    if !recentPhrases.isEmpty {
                        categoryButton(category: nil, text: "Recents")
                            .id(0)
                            .transition(.opacity.animation(.easeInOut))
                    }
                    
                    ForEach(categories) { category in
                        categoryButton(category: category, text: category.title)
                    }
                }
                .animation(.easeInOut, value: recentPhrases.count)
                .padding(.horizontal)
                .onChange(of: selectedCategory) { category in
                    withAnimation {
                        if category == nil {
                            value.scrollTo(0, anchor: .trailing)
                        } else {
                            value.scrollTo(category?.id, anchor: .trailing)
                        }
                    }
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
    private func categoryButton(category: PhraseCategory?, text: String) -> some View {
        Button {
            withAnimation {
                selectedCategory = category
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
}

#Preview {
    CategorySelectorView(selectedCategory: .constant(nil))
        .environmentObject(ViewModel())
}
