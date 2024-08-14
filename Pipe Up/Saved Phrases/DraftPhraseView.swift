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
    
    let isEditing: Bool

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
                Text("Labels can help you identify longer phrases quickly.")
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
        }
    }
}

#Preview {
    DraftPhraseView(draftPhrase: DraftPhrase(), isEditing: false)
}
