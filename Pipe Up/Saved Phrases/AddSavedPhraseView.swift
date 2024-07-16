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
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.title_, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    
    @State private var phraseText = ""
    @State private var phraseLabel = ""
    @State private var isAddingCategory = false
    @State private var categoryTitle = ""
    @State private var selectedCategory: PhraseCategory?
    @State private var showingDuplicateCategoryAlert = false
    
    @FocusState var isInputActive: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Type your phrase here...", text: $phraseText, axis: .vertical)
                        .lineLimit(5)
                        .focused($isInputActive)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                isInputActive = true
                            }
                        }
                    
                    TextField("Label (optional)", text: $phraseLabel)
                } footer: {
                    Text("Labels can help you identify longer phrases quickly.")
                }
                
                Section {
                    Picker("Category", selection: $selectedCategory) {
                        // Includes the "General" option (i.e. nil) in the Picker list
                        Text("General").tag(nil as PhraseCategory?)
                        
                        ForEach(categories, id: \.self) {
                            Text($0.title).tag(Optional($0))
                        }
                    }
                    
                    Button("Add New Category") {
                        isAddingCategory = true
                    }
                }
            }
            .navigationTitle("Add New Phrase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Phrase") {
                        addPhrase()
                        dismiss()
                    }
                    .disabled(phraseText == "" ? true : false)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Add Category", isPresented: $isAddingCategory) {
                TextField("Category Title", text: $categoryTitle)
                Button("Save") {
                    addCategory()
                    categoryTitle = ""
                }
                Button("Cancel", role: .cancel) { categoryTitle = "" }
            }
            .alert("Duplicate Category", isPresented: $showingDuplicateCategoryAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("This category title already exists. Please select a different title.")
            }
        }
    }
    
    // Adds a new phrase and assigns a category, using the currently-selected category
    func addPhrase() {
        let newSavedPhrase = SavedPhrase(context: context)
        if let selectedCategory {
            newSavedPhrase.category = selectedCategory
        }
        newSavedPhrase.text = phraseText
        if !phraseLabel.isEmpty {
            newSavedPhrase.label = phraseLabel
        }
        
        try? context.save()
    }
    
    // Adds a new category
    func addCategory() {
        if categories.contains(where: { $0.title == categoryTitle }) {
            showingDuplicateCategoryAlert = true
        } else {
            let newCategory = PhraseCategory(context: context)
            newCategory.title = categoryTitle
        
            try? context.save()
            
            selectedCategory = newCategory
        }
    }
}

#Preview {
    AddSavedPhraseView()
}
