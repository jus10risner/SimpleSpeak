//
//  DraftPhraseView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/19/24.
//

import SwiftUI

struct DraftPhraseView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var draftPhrase: DraftPhrase
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.title_, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    
    @State private var isAddingCategory = false
    @State private var categoryTitle = ""
    @State private var showingDuplicateCategoryAlert = false
    
    @FocusState var isInputActive: Bool
    
    var body: some View {
        Form {
            Section {
                TextField("Phrase", text: $draftPhrase.text, axis: .vertical)
                    .lineLimit(5)
                    .focused($isInputActive)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                            isInputActive = true
                        }
                    }
                
                TextField("Label (optional)", text: $draftPhrase.label)
            } footer: {
                Text("Labels can help you identify longer phrases quickly.")
            }
            
            Section {
//                Picker("Category", selection: $selectedCategory) {
                Picker("Category", selection: $draftPhrase.category) {
                    // Includes the "General" option (i.e. nil) in the Picker list
                    Text("General").tag(nil as PhraseCategory?)
                    
                    ForEach(categories, id: \.id) {
                        Text($0.title).tag(Optional($0))
                    }
                }
                
                Button("Add New Category") {
                    isAddingCategory = true
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
    
    // Adds a new category
    func addCategory() {
        if categories.contains(where: { $0.title == categoryTitle }) {
            showingDuplicateCategoryAlert = true
        } else {
            let newCategory = PhraseCategory(context: context)
            newCategory.id = UUID()
            newCategory.title = categoryTitle
        
            try? context.save()
            
            draftPhrase.category = newCategory
        }
    }
}

#Preview {
    DraftPhraseView(draftPhrase: DraftPhrase())
}
