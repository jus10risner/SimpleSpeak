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
    @FetchRequest(sortDescriptors: []) var categories: FetchedResults<PhraseCategory>
    
    @State private var showingAddPhrase = false
    
    var body: some View {
        NavigationStack {
//            allSavedPhrases
            categoryList
                .navigationTitle("Saved Phrases")
                .listRowSpacing(5)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
                .scrollDismissesKeyboard(.interactively)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingAddPhrase = true
                        } label: {
                            Label("Add New Phrase", systemImage: "plus")
                        }
                    }
                    
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Button("Clear All") {
                            for item in savedPhrases {
                                context.delete(item)
                                try? context.save()
                            }
                        }
                        
                        
                    }
                }
                .sheet(isPresented: $showingAddPhrase) {
                    AddSavedPhraseView()
                }
        }
    }
    
    // List of categories, with navigation links to their respective phrases
    private var categoryList: some View {
        List {
            ZStack {
                Color.clear
                NavigationLink("General") {
                    uncategorizedPhrasesList
                        .navigationTitle("General")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            
            ForEach(categories) { category in
                NavigationLink {
                    // TODO: Create category view, for listing phrases saved in a given category
                    // Navigate to list of phrases for this category
                    Text("Category: \(category.title)")
                } label: {
                    Text(category.title)
                }
            }
        }
    }
    
    // List of phrases with no category
    private var uncategorizedPhrasesList: some View {
        List {
            ForEach(savedPhrases) { phrase in
                if phrase.category == nil {
                    Button {
                        vm.speak(phrase.text)
                    } label: {
                        Text(phrase.text)
                            .foregroundStyle(Color.primary)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            withAnimation(.easeInOut) {
                                context.delete(phrase)
                                try? context.save()
                            }
                        } label: {
                            Label("Delete Phrase", systemImage: "trash")
                                .labelStyle(.iconOnly)
                        }
                        .tint(Color.red)
                    }
                }
            }
        }
    }
    
    // List of all saved phrases
    private var allSavedPhrases: some View {
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
                        withAnimation(.easeInOut) {
                            context.delete(phrase)
                            try? context.save()
                        }
                    } label: {
                        Label("Delete Phrase", systemImage: "trash")
                            .labelStyle(.iconOnly)
                    }
                    .tint(Color.red)
                }
            }
        }
    }
}

#Preview {
    SavedPhrasesView()
        .environmentObject(ViewModel())
}
