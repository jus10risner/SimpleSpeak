//
//  AddSavedPhraseView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 8/5/24.
//

import SwiftUI

struct AddSavedPhraseView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @StateObject var draftPhrase: DraftPhrase
    
    let category: PhraseCategory?
    
    init(category: PhraseCategory?) {
        self.category = category
        
        _draftPhrase = StateObject(wrappedValue: DraftPhrase())
    }
    
    var body: some View {
        NavigationStack {
            DraftPhraseView(draftPhrase: draftPhrase, isEditing: false, savedPhrase: nil)
                .navigationTitle("Add New Phrase")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    draftPhrase.category = category
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    AddSavedPhraseView(category: nil)
}
