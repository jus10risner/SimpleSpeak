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
    
    @State private var hasChanges = false
    
    init(category: PhraseCategory?, savedPhrase: SavedPhrase) {
        self.category = category
        self.savedPhrase = savedPhrase
        
        _draftPhrase = StateObject(wrappedValue: DraftPhrase(savedPhrase: savedPhrase))
    }
    
    var body: some View {
        NavigationStack {
            DraftPhraseView(draftPhrase: draftPhrase, isEditing: true)
                .navigationTitle("Edit Phrase")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    if let category {
                        draftPhrase.category = category
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            savedPhrase.updatePhrase(draftPhrase: draftPhrase)
                            
                            dismiss()
                        }
                        .disabled(hasChanges && draftPhrase.canBeSaved ? false : true)
                    }
                }
                .onChange(of: draftPhraseData) { _ in
                    hasChanges = true
                }
        }
    }
    
    // Used to detect changes in draftPhrase's published properties; used to determine whether the Save button is enabled
    private var draftPhraseData: [String?] {
        return [draftPhrase.text, draftPhrase.label, draftPhrase.category?.description]
    }
}

#Preview {
    EditSavedPhraseView(category: nil, savedPhrase: SavedPhrase(context: DataController.preview.container.viewContext))
}
