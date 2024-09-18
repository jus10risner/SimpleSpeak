//
//  SavedPhrasesListView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/11/24.
//

import SwiftUI

struct SavedPhrasesListView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: ViewModel
    
//    @FetchRequest(sortDescriptors: []) var categories: FetchedResults<PhraseCategory>
    @FetchRequest var savedPhrases: FetchedResults<SavedPhrase>
    
    let category: PhraseCategory?
    
    @State private var showingAddPhrase = false
    @State private var showingDeleteAlert = false
    @State private var showingEditCategory = false
    @State private var categoryTitle = ""
    
    // Custom init, so I can pass in the optional "category" property as a predicate
    init(category: PhraseCategory?) {
        self.category = category
        let predicate = NSPredicate(format: "category == %@", category ?? NSNull())
        
        self._savedPhrases = FetchRequest(entity: SavedPhrase.entity(), sortDescriptors: [
            NSSortDescriptor(
                keyPath: \SavedPhrase.displayOrder,
                ascending: category == nil ? false : true)
        ], predicate: predicate)
    }
    
    var body: some View {
        List {
            ForEach(savedPhrases) { phrase in
                NavigationLink {
                    EditSavedPhraseView(category: category, savedPhrase: phrase)
                } label: {
                    if phrase.label != "" {
                        Text(phrase.label)
                    } else {
                        Text(phrase.text)
                    }
                }
                .foregroundStyle(Color.primary)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        context.delete(phrase)
                        try? context.save()
                    } label: {
                        Label("Delete Phrase", systemImage: "trash")
                            .labelStyle(.iconOnly)
                    }
                    .tint(Color.red)
                }
            }
            .onMove(perform: { indices, newOffset in
                move(from: indices, to: newOffset)
            })
            .onDelete(perform: { indexSet in
                vm.deletePhrase(at: indexSet, from: savedPhrases)
            })
        }
        .navigationTitle(category?.title ?? "Recents")
        .navigationBarTitleDisplayMode(.inline)
        .listRowSpacing(vm.listRowSpacing)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if category != nil {
                    Button {
                        showingAddPhrase = true
                    } label: {
                        Label("Add New Phrase", systemImage: "plus")
                    }
                    
//                    if category?.title != "Saved" {
//                        categoryMenu
//                    }
                }
            }
            
            if category?.title != "Favorites" && category != nil {
                ToolbarTitleMenu {
                    categoryMenu
                }
            }
            
//            ToolbarTitleMenu {
//                categoryMenu
//            }
        }
        .onAppear {
            if let category {
                categoryTitle = category.title
            }
        }
        .overlay {
            if savedPhrases.count == 0 {
                if category != nil {
                    EmptyListView(systemImage: "bookmark", headline: "No Phrases", subheadline: "Tap the plus button to add a phrase.")
                } else {
                    EmptyListView(systemImage: "clock.arrow.circlepath", headline: "No Recents", subheadline: nil)
                }
            }
        }
        .sheet(isPresented: $showingAddPhrase) {
            AddSavedPhraseView(category: category)
        }
        .alert("Edit Category Name", isPresented: $showingEditCategory) {
            TextField("Category Title", text: $categoryTitle )
                
            Button("Save") {
                category?.updateCategory(title: categoryTitle)
            }
            .disabled(categoryTitle == "" ? true : false)
            Button("Cancel", role: .cancel) { 
                categoryTitle = category?.title ?? ""
            }
        }
        .confirmationDialog("Delete Category", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let category {
                    context.delete(category)
                }
                try? context.save()
                
                dismiss()
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Delete this category and all associated phrases?\nThis cannot be undone.")
        }
    }
    
    private var categoryMenu: some View {
        Group {
            Button {
                // TODO: Add EditCategoryView
                showingEditCategory = true
            } label: {
                Label("Edit Category", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                // TODO: Add deleteCategory() method
                showingDeleteAlert = true
            } label: {
                Label("Delete Category", systemImage: "trash")
            }
        }
    }
    
    // Persists the order of phrases, after moving
    func move(from source: IndexSet, to destination: Int) {
        // Make an array of phrases from fetched results
        var modifiedPhraseList: [SavedPhrase] = savedPhrases.map { $0 }

        // change the order of the phrases in the array
        modifiedPhraseList.move(fromOffsets: source, toOffset: destination )

        // update the displayOrder attribute in modifiedPhraseList to
        // persist the new order.
        for index in (0..<modifiedPhraseList.count) {
            modifiedPhraseList[index].displayOrder = Int64(index)
        }
        
        try? context.save()
    }
}

#Preview {
    SavedPhrasesListView(category: nil)
        .environmentObject(ViewModel())
}
