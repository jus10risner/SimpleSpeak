//
//  AddSavedPhraseView.swift
//  Pipe Up
//
//  Created by Justin Risner on 8/5/24.
//

import SwiftUI

struct AddSavedPhraseView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @StateObject var draftPhrase = DraftPhrase()
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SavedPhrase.displayOrder, ascending: true)]) var allPhrases: FetchedResults<SavedPhrase>
    @FetchRequest var categoryPhrases: FetchedResults<SavedPhrase>
    
    let category: PhraseCategory?
    
    @State private var showingDuplicateAlert = false
    
    init(category: PhraseCategory?) {
        self.category = category
        let predicate = NSPredicate(format: "category == %@", category ?? NSNull())
        
        self._categoryPhrases = FetchRequest(entity: SavedPhrase.entity(), sortDescriptors: [], predicate: predicate)
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
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            if categoryPhrases.contains(where: { $0.text == draftPhrase.text }) {
                                showingDuplicateAlert = true
                            } else {
                                addPhrase()
                                dismiss()
                            }
                        }
                        .disabled(draftPhrase.canBeSaved ? false : true)
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                .alert("Duplicate Phrase", isPresented: $showingDuplicateAlert) {
                    Button("OK", role: .cancel) {  }
                } message: {
                    Text("This phrase already exists in the selected category. Please select a different category, or enter a new phrase.")
                }
        }
    }
    
    // Adds a new phrase and assigns a category, using the currently-selected category
    func addPhrase() {
        let newSavedPhrase = SavedPhrase(context: context)
        newSavedPhrase.id = UUID()
        newSavedPhrase.text = draftPhrase.text
        if !draftPhrase.label.isEmpty {
            newSavedPhrase.label = draftPhrase.label
        }
        if let category = draftPhrase.category {
            newSavedPhrase.category = category
        }
        newSavedPhrase.displayOrder = (allPhrases.last?.displayOrder ?? 0) + 1
        
        try? context.save()
    }
}

#Preview {
    AddSavedPhraseView(category: nil)
}
