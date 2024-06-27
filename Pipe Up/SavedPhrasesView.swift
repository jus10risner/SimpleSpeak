//
//  SavedPhrasesView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/19/24.
//

import SwiftUI

struct SavedPhrasesView: View {
    @EnvironmentObject var vm: ViewModel
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: []) var savedPhrases: FetchedResults<SavedPhrase>
    
    @State private var showingTextEntry = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(savedPhrases) { phrase in
                    Button {
                        vm.speak(phrase.text)
                    } label: {
                        Text(phrase.text)
                            .foregroundStyle(Color.primary)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            context.delete(phrase)
                            try? context.save()
                        } label: {
                            Label("Delete Phrase", systemImage: "trash")
                                .labelStyle(.iconOnly)
                        }
                        .tint(Color.red)
                    }
                }
            }
            .listRowSpacing(5)
            .navigationTitle("Saved Phrases")
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingTextEntry = true
                    } label: {
                        Label("Add New Phrase", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingTextEntry, content: {
                AddSavedPhraseView()
                    .presentationDetents([.medium])
            })
        }
    }
}

#Preview {
    SavedPhrasesView()
        .environmentObject(ViewModel())
}
