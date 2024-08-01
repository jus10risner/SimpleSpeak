//
//  DraftPhraseView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/19/24.
//

import SwiftUI

struct DraftPhraseView: View {
    @ObservedObject var draftPhrase: DraftPhrase
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.title_, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    
    @State private var selectedCategory: PhraseCategory?
    @State private var isAddingCategory = false
    
    @FocusState var isInputActive: Bool
    
    var body: some View {
        Form {
            Section {
                TextField("Type your phrase here...", text: $draftPhrase.text, axis: .vertical)
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
                Picker("Category", selection: $selectedCategory) {
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
    }
}

#Preview {
    DraftPhraseView(draftPhrase: DraftPhrase())
}
