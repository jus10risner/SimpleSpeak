//
//  SavedPhrasesView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/19/24.
//

import SwiftUI

struct SavedPhrasesView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var vm: ViewModel
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.title_, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    
    @State private var showingAddPhrase = false
    
    var body: some View {
        NavigationStack {
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
                    
//                    ToolbarItemGroup(placement: .topBarLeading) {
//                        Button("Clear All") {
//                            for item in savedPhrases {
//                                context.delete(item)
//                                try? context.save()
//                            }
//                        }
//                        
//                        
//                    }
                }
                .sheet(isPresented: $showingAddPhrase) {
                    AddSavedPhraseView()
                }
        }
    }
    
    // List of categories, with navigation links to their respective phrases
    private var categoryList: some View {
        List {
            if categories.count == 0 {
                SavedPhrasesListView(category: nil)
            } else {
                ZStack {
                    Color.clear
                    NavigationLink("General") {
                        SavedPhrasesListView(category: nil)
                    }
                }
                
                ForEach(categories) { category in
                    NavigationLink {
                        SavedPhrasesListView(category: category)
                    } label: {
                        Text(category.title)
                    }
                }
            }
        }
    }
}

#Preview {
    SavedPhrasesView()
        .environmentObject(ViewModel())
}
