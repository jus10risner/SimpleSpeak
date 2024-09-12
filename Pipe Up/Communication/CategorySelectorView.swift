//
//  CategorySelectorView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/11/24.
//

import SwiftUI

struct CategorySelectorView: View {
    @EnvironmentObject var vm: ViewModel
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.title_, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "category == %@", NSNull())) var recentPhrases: FetchedResults<SavedPhrase>
    
    @Binding var selectedCategory: PhraseCategory?
    
    let rows = [GridItem(.adaptive(minimum: 150), spacing: 5)]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 10) {
                if !recentPhrases.isEmpty {
                    categoryButton(category: nil, text: "Recents")
                }
                
                ForEach(categories) { category in
                    if category.phrases?.count != 0 {
                        categoryButton(category: category, text: category.title)
                    }
                }
            }
            .padding(.horizontal)
        }
//        .frame(height: 50)
        .padding(.vertical, 10)
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            // Selects the first category that contains phrases, if the currently-selected category (or Recents) is empty
            if recentPhrases.isEmpty {
                selectedCategory = categories.first(where: { $0.phrases?.count != 0 })
            } else if selectedCategory?.phrases?.count == 0 {
                selectedCategory = categories.first(where: { $0.phrases?.count != 0 })
            }
        }
    }
    
    // Category selection button
    private func categoryButton(category: PhraseCategory?, text: String) -> some View {
        Button {
            selectedCategory = category
        } label: {
            Text(text)
                .font(.title.bold())
                .foregroundStyle(selectedCategory == category ? Color.primary : Color.secondary)
//                .underline(selectedCategory == category ? true : false, pattern: .solid, color: Color(.defaultAccent))
//                .padding()
//                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
        }
//        .overlay {
//            if selectedCategory == category {
//                RoundedRectangle(cornerRadius: vm.cornerRadius)
//                    .stroke(Color.secondary, lineWidth: 0.5)
//            }
//        }
    }
}

#Preview {
    CategorySelectorView(selectedCategory: .constant(nil))
        .environmentObject(ViewModel())
}
