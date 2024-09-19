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
    @StateObject var draftPhrase: DraftPhrase

    let category: PhraseCategory?
    let savedPhrase: SavedPhrase
    
    init(category: PhraseCategory?, savedPhrase: SavedPhrase) {
        self.category = category
        self.savedPhrase = savedPhrase
        
        _draftPhrase = StateObject(wrappedValue: DraftPhrase(savedPhrase: savedPhrase))
    }
    
    var body: some View {
        NavigationStack {
            DraftPhraseView(draftPhrase: draftPhrase, isEditing: true, savedPhrase: savedPhrase)
                .navigationTitle("Edit Phrase")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    EditSavedPhraseView(category: nil, savedPhrase: SavedPhrase(context: DataController.preview.container.viewContext))
}
