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
                            Label("Add New Phrase", systemImage: "plus.circle.fill")
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
                    AddSavedPhraseView(category: nil)
                }
        }
    }
    
    // List of categories, with navigation links to their respective phrases
    // ZStacks and clear colors were added, due to jumpy navigation behavior on iOS 16
    private var categoryList: some View {
        if categories.count == 0 {
            AnyView(SavedPhrasesListView(category: nil))
        } else {
            AnyView(
                List {
                    ZStack {
                        Color.clear
                        NavigationLink("General") {
                            SavedPhrasesListView(category: nil)
                                .navigationTitle("General")
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                    
                    ForEach(categories, id: \.id) { category in
                        ZStack {
                            Color.clear
                            NavigationLink(category.title) {
                                SavedPhrasesListView(category: category)
                                    .navigationTitle(category.title)
                                    .navigationBarTitleDisplayMode(.inline)
                            }
                        }
                    }
                    
                    // TODO: Remove this, when finished testing
                    #if DEBUG
                    Button("Clear Categories") {
                        for category in categories {
                            context.delete(category)
                            try? context.save()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    #endif
                }
                .listRowSpacing(vm.listRowSpacing)
            )
        }
    }
}

#Preview {
    SavedPhrasesView()
        .environmentObject(ViewModel())
}
