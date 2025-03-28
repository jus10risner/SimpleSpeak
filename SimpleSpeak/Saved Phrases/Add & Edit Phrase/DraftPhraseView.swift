//
//  DraftPhraseView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 7/19/24.
//

import SwiftUI

struct DraftPhraseView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @ObservedObject var draftPhrase: DraftPhrase
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.title_, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SavedPhrase.displayOrder, ascending: true)]) var phrases: FetchedResults<SavedPhrase>
    
    let isEditing: Bool
    let savedPhrase: SavedPhrase?
    
    @State private var showingDeleteAlert = false
    @State private var showingDuplicateAlert = false
    @State private var hasChanges = false
    
    private var placeholder: String { draftPhrase.text.isEmpty ? " " : draftPhrase.text } // Used by phraseField

    @FocusState var isInputActive: Bool
    
    var body: some View {
        Form {
            Section {
                phraseField
                
                LabeledContent("Label") {
                    TextField("Optional", text: $draftPhrase.label, axis: .vertical)
                        .padding(.leading, 10)
                        .lineLimit(1)
                }
            } footer: {
                Text("Use a label to help quickly identify a longer phrase.")
            }
            
            Section {
                Picker("Category", selection: $draftPhrase.category) {
                    if draftPhrase.category == nil {
                        Text("None").tag(nil as PhraseCategory?)
                    }
                    
                    ForEach(categories) {
                        Text($0.title).tag($0 as PhraseCategory?)
                    }
                }
            } footer: {
                if draftPhrase.category == nil {
                    Text("Please select a category for this phrase.")
                }
            }
            
            if isEditing {
                Button("Delete Phrase", role: .destructive) {
                    showingDeleteAlert = true
                }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onChange(of: draftPhraseData) { _ in
            hasChanges = true
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    if canSavePhrase {
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
    
    // Custom labeled TextField, to work around alignment issues and VoiceOver struggles, both related to the 'axis: .vertical' TextField property
    private var phraseField: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Phrase")
                .accessibilityHidden(true)
            
            TextField("Required", text: .constant(placeholder), axis: .vertical)
                .opacity(0)
                .lineLimit(5)
                .overlay {
                    TextField("Required", text: $draftPhrase.text, axis: .vertical)
                        .padding(.leading, 10)
                        .accessibilityLabel("Phrase")
                        .focused($isInputActive)
                        .onAppear {
                            if isEditing == false {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                    isInputActive = true
                                }
                            }
                        }
                }
        }
    }
    
    private var canSavePhrase: Bool {
        let containsMatchingPhrase = phrases.contains { phrase in
            phrase.category == draftPhrase.category &&
            (phrase.text.normalized == draftPhrase.text.normalized || (!phrase.label.isEmpty && phrase.label.normalized == draftPhrase.label.normalized)) &&
            phrase.id != draftPhrase.id
        }
        
        if containsMatchingPhrase {
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
    
    // Used with onChange, to detect changes in draftPhrase's published properties, to determine whether the Save button is enabled
    private var draftPhraseData: [String?] {
        return [draftPhrase.text, draftPhrase.label, draftPhrase.category?.description]
    }
    
    // Adds a new phrase and assigns a category, using the currently-selected category
    func addPhrase() {
        let newSavedPhrase = SavedPhrase(context: context)
        newSavedPhrase.id = UUID()
        newSavedPhrase.text = draftPhrase.text.trimmingCharacters(in: .whitespacesAndNewlines)
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
