//
//  PhraseCardView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/11/24.
//

import SwiftUI

struct PhraseCardView: View {
    @EnvironmentObject var vm: ViewModel
    @FetchRequest(sortDescriptors: []) var savedPhrases: FetchedResults<SavedPhrase>
    
    @Binding var selectedCategory: PhraseCategory?
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 5)]
    
    var body: some View {
        ScrollView {
//            VStack {
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(filteredPhrases, id: \.self) { phrase in
                        Button {
                            vm.speak(phrase.text)
                        } label: {
                            HStack(spacing: 10) {
                                Text(phrase.text)
                                    .foregroundStyle(Color.primary)
                                    .frame(maxWidth: .infinity)
//                                    .multilineTextAlignment(.leading)
                                
//                                Spacer()
//
//                                VStack {
//                                    Button {
//                                        // Save phrase to Saved Phrases
//                                        if !savedPhrases.contains(where: { phrase.text == $0.text }) {
//                                            let newPhrase = SavedPhrase(context: context)
//                                            newPhrase.text = phrase.text
//
//                                            try? context.save()
//                                        }
//                                    } label: {
//                                        Label("Save Phrase", systemImage: savedPhrases.contains(where: { phrase.text == $0.text }) ? "bookmark.fill" : "bookmark")
//                                            .labelStyle(.iconOnly)
//                                    }
//
//                                    Spacer()
//
//                                    Button(role: .destructive) {
//                                        withAnimation(.easeInOut) {
//                                            context.delete(phrase)
//                                            try? context.save()
//                                        }
//                                    } label: {
//                                        Label("Delete Phrase", systemImage: "trash")
//                                            .labelStyle(.iconOnly)
//                                    }
//                                    .opacity(isEditing ? 1 : 0)
//                                    .animation(.easeInOut(duration: 0.1), value: isEditing)
//                                }
                            }
                            .padding(20)
                            .frame(height: 100)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
                        }
                    }
                }
                .padding()
                
//                Spacer()
//            }
//            .padding()
        }
    }
    
    // Returns the phrases in the selected category
    private var filteredPhrases: [SavedPhrase] {
        return savedPhrases.filter({ $0.category == selectedCategory })
    }
}

#Preview {
    PhraseCardView(selectedCategory: .constant(nil))
}
