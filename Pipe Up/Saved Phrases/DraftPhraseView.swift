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
    @FetchRequest(sortDescriptors: []) var phrases: FetchedResults<SavedPhrase>
    
    let isEditing: Bool
    let savedPhrase: SavedPhrase?
    
    @State private var showingDeleteAlert = false
    @State private var showingDuplicateAlert = false
    @State private var hasChanges = false

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
        .onAppear {
            phrases.nsPredicate = NSPredicate(format: "category == %@", draftPhrase.category ?? NSNull())
        }
        .onChange(of: draftPhrase.category) { newCategory in
            phrases.nsPredicate = NSPredicate(format: "category == %@", newCategory ?? NSNull())
        }
        .onChange(of: draftPhraseData) { _ in
            hasChanges = true
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    if canSave {
                        savePhrase()
                    } else {
                        showingDuplicateAlert = true
                    }
                }
                .disabled(hasChanges && draftPhrase.canBeSaved ? false : true)
            }
        }
        .alert("Duplicate Phrase", isPresented: $showingDuplicateAlert) {
            Button("OK", role: .cancel) {  }
        } message: {
            Text("This phrase or label already exists in the selected category. Please select a different category, or enter a new phrase or label.")
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
    
    private var canSave: Bool {
        if phrases.contains(where: { $0.category == draftPhrase.category && ($0.text == draftPhrase.text || ($0.label != "" && $0.label == draftPhrase.label)) && $0.id != draftPhrase.id }) {
            return false
        } else {
            return true
        }
    }
    
    func savePhrase() {
        if isEditing {
            savedPhrase?.update(draftPhrase: draftPhrase)
        } else {
            addPhrase()
        }
        
        dismiss()
    }
    
    // Used to detect changes in draftPhrase's published properties, to determine whether the Save button is enabled
    private var draftPhraseData: [String?] {
        return [draftPhrase.text, draftPhrase.label, draftPhrase.category?.description]
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
        newSavedPhrase.displayOrder = (phrases.last?.displayOrder ?? 0) + 1
        
        try? context.save()
    }
}

#Preview {
    DraftPhraseView(draftPhrase: DraftPhrase(), isEditing: false, savedPhrase: nil)
}
