//
//  CategorySelectorView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/11/24.
//

import SwiftUI

struct CategorySelectorView: View {
    @EnvironmentObject var vm: ViewModel
    @FetchRequest(sortDescriptors: []) var categories: FetchedResults<PhraseCategory>
    
    @Binding var selectedCategory: PhraseCategory?
    @Binding var showingRecents: Bool
    
    let rows = [ GridItem(.adaptive(minimum: 150), spacing: 5) ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 5) {
                recentPhrasesButton()
                
                categoryButton(category: nil, text: "General")
                
                ForEach(categories, id: \.id) { category in
                    if category.phrases?.count != 0 {
                        categoryButton(category: category, text: category.title)
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 75)
//        .padding(.bottom, 5)
    }
    
    private func recentPhrasesButton() -> some View {
        Button {
            showingRecents = true
            selectedCategory = nil
        } label: {
            Text("Recents")
                .foregroundStyle(Color.primary)
                .padding(15)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15))
        }
        .overlay {
            if selectedCategory == nil && showingRecents == true {
                RoundedRectangle(cornerRadius: vm.cornerRadius)
                    .stroke(Color.secondary, lineWidth: 0.5)
            }
        }
    }
    
    // Category selection button
    private func categoryButton(category: PhraseCategory?, text: String) -> some View {
        Button {
            showingRecents = false
            selectedCategory = category
        } label: {
            Text(text)
                .foregroundStyle(Color.primary)
                .padding(15)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15))
        }
        .overlay {
            if selectedCategory == category && showingRecents == false {
                RoundedRectangle(cornerRadius: vm.cornerRadius)
                    .stroke(Color.secondary, lineWidth: 0.5)
            }
        }
    }
}

#Preview {
    CategorySelectorView(selectedCategory: .constant(nil), showingRecents: .constant(false))
        .environmentObject(ViewModel())
}
