//
//  EditSavedPhraseView.swift
//  Pipe Up
//
//  Created by Justin Risner on 8/8/24.
//

import SwiftUI

struct EditSavedPhraseView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @StateObject var draftPhrase = DraftPhrase()
    
    let category: PhraseCategory?
    let savedPhrase: SavedPhrase
    
    @State private var selectedCategory: PhraseCategory?
    @State private var categoryTitle = ""
    @State private var showingDuplicateCategoryAlert = false
    
    init(category: PhraseCategory?, savedPhrase: SavedPhrase) {
        self.category = category
        self.savedPhrase = savedPhrase
        
        _draftPhrase = StateObject(wrappedValue: DraftPhrase(savedPhrase: savedPhrase))
    }
    
    var body: some View {
        NavigationStack {
            DraftPhraseView(draftPhrase: draftPhrase)
                .navigationTitle("Edit Phrase")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    if let category {
                        selectedCategory = category
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            savedPhrase.updatePhrase(draftPhrase: draftPhrase)
                            
                            dismiss()
                        }
                        .disabled(draftPhrase.canBeSaved ? false : true)
                    }
                }
        }
    }
}

#Preview {
    EditSavedPhraseView(category: nil, savedPhrase: SavedPhrase(context: DataController.preview.container.viewContext))
}
