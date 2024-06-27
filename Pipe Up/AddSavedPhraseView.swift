//
//  AddSavedPhraseView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/26/24.
//

import SwiftUI

struct AddSavedPhraseView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var context
    @State private var text = ""
    @FocusState var isInputActive: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Type your phrase here...", text: $text, axis: .vertical)
                        .lineLimit(5)
                        .focused($isInputActive)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Phrase") {
                        let newSavedPhrase = SavedPhrase(context: context)
                        newSavedPhrase.text = text
                        
                        try? context.save()
                    }
                }
                
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
    AddSavedPhraseView()
}
