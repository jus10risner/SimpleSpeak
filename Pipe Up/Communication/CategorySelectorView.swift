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
    @Binding var showingAddCategory: Bool
    
    let rows = [GridItem(.adaptive(minimum: 150))]
    
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
                    
                    addCategoryButton
                        .id(1)
                }
                .animation(.easeInOut, value: recentPhrases.count) // Lets the Recents category selector animate in smoothly
                .padding(.horizontal)
            }
            .onChange(of: selectedCategory) { category in
                withAnimation {
                    scrollToSelectedCategory(category: category, value: value)
                }
            }
//            .background(Color(.secondarySystemBackground))
//            .frame(maxHeight: 70)
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
            }
        } label: {
            HStack {
                Image(systemName: category?.symbolName ?? "clock.arrow.circlepath")
//                    .foregroundStyle(selectedCategory == category ? Color(.defaultAccent) : Color.secondary)
                    .accessibilityHidden(true)
                
                if selectedCategory == category {
                    Text(text)
                }
            }
            .font(.headline)
            .foregroundStyle(selectedCategory == category ? Color.white : Color.secondary)
            .padding()
            .frame(height: 50)
            .background(selectedCategory == category ? Color(.defaultAccent) : Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
//            .overlay {
//                RoundedRectangle(cornerRadius: vm.cornerRadius)
//                    .stroke(selectedCategory == category ? Color.primary : Color.secondary, lineWidth: 2)
//            }
            .mask(RoundedRectangle(cornerRadius: vm.cornerRadius))
            .drawingGroup()
                
        }
        .padding(.vertical)
        .accessibilityLabel(selectedCategory == category ? "\(text), category, selected" : "\(text), category")
    }
    
    private var addCategoryButton: some View {
        Button {
            showingAddCategory = true
        } label: {
            Label("Add Category", systemImage: "plus")
                .labelStyle(.iconOnly)
                .font(.headline)
                .padding()
                .frame(height: 50)
                .overlay {
                    RoundedRectangle(cornerRadius: vm.cornerRadius)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundStyle(Color.secondary)
                        .opacity(0.5)
                }
        }
    }
    
    func scrollToSelectedCategory(category: PhraseCategory?, value: ScrollViewProxy) {
        value.scrollTo(category?.id, anchor: .center)
    }
}

#Preview {
    CategorySelectorView(selectedCategory: .constant(nil), showingAddCategory: .constant(false))
        .environmentObject(ViewModel())
}
