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
//    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "category == %@", NSNull())) var recentPhrases: FetchedResults<SavedPhrase>
    
    @Binding var selectedCategory: PhraseCategory?
    
    let rows = [GridItem(.adaptive(minimum: 150), spacing: 5)]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { value in
                LazyHGrid(rows: rows, spacing: 5) {
//                    if !recentPhrases.isEmpty {
                        categoryButton(category: nil, text: "Recents")
                            .id(0)
//                    }
                    
                    ForEach(categories) { category in
//                        if category.phrases?.count != 0 {
                            categoryButton(category: category, text: category.title)
//                        }
                    }
                }
//                .frame(height: 50)
//                .frame(maxHeight: .infinity)
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
//        .frame(height: 30)
//        .padding(.bottom, 5)
        .fixedSize(horizontal: false, vertical: true)
//        .onAppear {
//            // Selects the first category that contains phrases, if the currently-selected category (or Recents) is empty
//            if recentPhrases.isEmpty {
//                selectedCategory = categories.first(where: { $0.phrases?.count != 0 })
//            } else if selectedCategory?.phrases?.count == 0 {
//                selectedCategory = categories.first(where: { $0.phrases?.count != 0 })
//            }
//        }
    }
    
    // Category selection button
    private func categoryButton(category: PhraseCategory?, text: String) -> some View {
        Button {
            selectedCategory = category
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
            .animation(.easeInOut, value: selectedCategory)
                
        }
        .accessibilityLabel(text)
//        .border(.secondary)
//        .frame(height: 44)
        .padding(.vertical)
//        .overlay {
//            if selectedCategory == category {
//                RoundedRectangle(cornerRadius: vm.cornerRadius)
//                    .stroke(Color(.defaultAccent), lineWidth: 2)
//            }
//        }
        
    }
}

#Preview {
    CategorySelectorView(selectedCategory: .constant(nil))
        .environmentObject(ViewModel())
}
