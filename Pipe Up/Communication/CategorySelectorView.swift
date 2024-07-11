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
    
    let rows = [ GridItem(.adaptive(minimum: 150), spacing: 5) ]
    
    @Binding var selectedCategory: PhraseCategory?
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows, spacing: 5) {
                Button {
                    selectedCategory = nil
                } label: {
                    Text("General")
                        .foregroundStyle(Color.primary)
                        .padding(15)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15))
                }
                .overlay {
                    if selectedCategory == nil {
                        RoundedRectangle(cornerRadius: vm.cornerRadius)
                            .stroke(Color.secondary, lineWidth: 0.5)
                    }
                }
                
                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category.title)
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
                
//                    ForEach(recentPhrases, id: \.self) { phrase in
//                        Button {
//                            vm.speak(phrase.text)
//                        } label: {
//                            HStack(spacing: 10) {
//                                Text(phrase.text)
//                                    .foregroundStyle(Color.primary)
//                                    .multilineTextAlignment(.leading)
//
//                                Spacer()
//
//                                Button {
//                                    // Save phrase to Saved Phrases
//                                    if !savedPhrases.contains(where: { phrase.text == $0.text }) {
//                                        let newPhrase = SavedPhrase(context: context)
//                                        newPhrase.text = phrase.text
//
//                                        try? context.save()
//                                    }
//                                } label: {
//                                    Label("Save Phrase", systemImage: savedPhrases.contains(where: { phrase.text == $0.text }) ? "bookmark.fill" : "bookmark")
//                                        .labelStyle(.iconOnly)
//                                }
//                            }
//                            .padding(15)
//                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15))
//                        }
//                    }
            }
            .padding(.horizontal)
        }
        .frame(height: 100)
        .padding(.bottom, 5)
    }
}

#Preview {
    CategorySelectorView(selectedCategory: .constant(nil))
}
