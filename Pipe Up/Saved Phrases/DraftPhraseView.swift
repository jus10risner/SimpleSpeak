//
//  DraftPhraseView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/19/24.
//

import SwiftUI

struct DraftPhraseView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @ObservedObject var draftPhrase: DraftPhrase
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.title_, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    
    let isEditing: Bool
    let savedPhrase: SavedPhrase?
    
    @State private var showingDeleteAlert = false

    @FocusState var isInputActive: Bool
    
    var body: some View {
        Form {
            Section {
                TextField("Phrase", text: $draftPhrase.text, axis: .vertical)
                    .lineLimit(5)
                    .focused($isInputActive)
                    .onAppear {
                        if isEditing == false {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                isInputActive = true
                            }
                        }
                    }
                
                TextField("Label (optional)", text: $draftPhrase.label)
            } footer: {
                Text("Use a label to quickly identify a longer phrase.")
            }
            
            Section("Category") {
                Picker("Category", selection: $draftPhrase.category) {
                    ForEach(categories) {
                        Text($0.title).tag(Optional($0))
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
            }
            
            if isEditing {
                Button("Delete Phrase", role: .destructive) {
                    showingDeleteAlert = true
                }
            }
        }
        .alert("Delete Phrase", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let savedPhrase {
                    context.delete(savedPhrase)
                    try? context.save()
                    
                    dismiss()
                }
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Permanently delete this phrase? This cannot be undone.")
        }
    }
}

#Preview {
    DraftPhraseView(draftPhrase: DraftPhrase(), isEditing: false, savedPhrase: nil)
}
