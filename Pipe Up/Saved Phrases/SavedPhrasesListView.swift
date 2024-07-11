//
//  SavedPhrasesListView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/11/24.
//

import SwiftUI

struct SavedPhrasesListView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var vm: ViewModel
    
    @FetchRequest(sortDescriptors: []) var savedPhrases: FetchedResults<SavedPhrase>
    
    let category: PhraseCategory?
    
    var body: some View {
        List {
            ForEach(filteredPhrases) { phrase in
                Button {
                    vm.speak(phrase.text)
                } label: {
                    Text(phrase.text)
                        .foregroundStyle(Color.primary)
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        withAnimation(.easeInOut) {
                            context.delete(phrase)
                            try? context.save()
                        }
                    } label: {
                        Label("Delete Phrase", systemImage: "trash")
                            .labelStyle(.iconOnly)
                    }
                    .tint(Color.red)
                }
            }
        }
        .listRowSpacing(vm.listRowSpacing)
        .navigationTitle(category?.title ?? "General")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Returns the phrases in the selected category
    private var filteredPhrases: [SavedPhrase] {
        return savedPhrases.filter({ $0.category == category })
    }
}

#Preview {
    SavedPhrasesListView(category: nil)
        .environmentObject(ViewModel())
}
