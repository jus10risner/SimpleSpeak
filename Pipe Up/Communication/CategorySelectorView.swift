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
    
    let rows = [ GridItem(.adaptive(minimum: 150), spacing: 5) ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 5) {
                categoryButton(category: nil, text: "General")
                
                ForEach(categories, id: \.id) { category in
                    categoryButton(category: category, text: category.title)
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 75)
//        .padding(.bottom, 5)
    }
    
    // Category selection button
    private func categoryButton(category: PhraseCategory?, text: String) -> some View {
        Button {
            selectedCategory = category
        } label: {
            Text(text)
                .foregroundStyle(Color.primary)
                .padding(15)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15))
        }
        .overlay {
            if selectedCategory == category {
                RoundedRectangle(cornerRadius: vm.cornerRadius)
                    .stroke(Color.secondary, lineWidth: 0.5)
            }
        }
    }
}

#Preview {
    CategorySelectorView(selectedCategory: .constant(nil))
        .environmentObject(ViewModel())
}
