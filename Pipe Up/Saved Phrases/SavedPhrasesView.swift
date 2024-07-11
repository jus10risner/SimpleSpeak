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
                .listRowSpacing(vm.listRowSpacing)
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
    // ZStacks and clear colors were added, due to jumpy navigation behavior on iOS 16
    private var categoryList: some View {
        List {
            ZStack {
                Color.clear
                NavigationLink("General") {
                    SavedPhrasesListView(category: nil)
                }
            }
            
            ForEach(categories) { category in
                ZStack {
                    Color.clear
                    NavigationLink {
                        SavedPhrasesListView(category: category)
                    } label: {
                        Text(category.title)
                    }
                }
            }
        }
        .listRowSpacing(vm.listRowSpacing)
    }
}

#Preview {
    SavedPhrasesView()
        .environmentObject(ViewModel())
}
