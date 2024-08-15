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
    
    @FetchRequest(sortDescriptors: []) var categories: FetchedResults<PhraseCategory>
    @FetchRequest var savedPhrases: FetchedResults<SavedPhrase>
    
    let category: PhraseCategory?
    
    @State private var showingAddPhrase = false
    @State private var showingDeleteAlert = false
    
    // Custom init, so I can pass in the optional "category" property as a predicate
    init(category: PhraseCategory?) {
        self.category = category
        let predicate = NSPredicate(format: "category == %@", category ?? NSNull())
        
        self._savedPhrases = FetchRequest(entity: SavedPhrase.entity(), sortDescriptors: [
            NSSortDescriptor(
                keyPath: \SavedPhrase.displayOrder,
                ascending: true),
            NSSortDescriptor(
                keyPath:\SavedPhrase.text_,
                ascending: true )
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
                    
                    if category?.title != "Saved" {
                        categoryMenu
                    }
                }
            }
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
        Menu {
            Button {
                // TODO: Add EditCategoryView
            } label: {
                Label("Edit Category", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                // TODO: Add deleteCategory() method
                showingDeleteAlert = true
            } label: {
                Label("Delete Category", systemImage: "trash")
            }
        } label: {
            Label("Edit Category", systemImage: "ellipsis.circle")
        }
    }
    
    // Persists the order of vehicles, after moving
    func move(from source: IndexSet, to destination: Int) {
        // Make an array of vehicles from fetched results
        var modifiedVehicleList: [SavedPhrase] = savedPhrases.map { $0 }

        // change the order of the vehicles in the array
        modifiedVehicleList.move(fromOffsets: source, toOffset: destination )

        // update the displayOrder attribute in modifiedVehicleList to
        // persist the new order.
        for index in (0..<modifiedVehicleList.count) {
            modifiedVehicleList[index].displayOrder = Int64(index)
        }
        
        try? context.save()
    }
}

#Preview {
    SavedPhrasesListView(category: nil)
        .environmentObject(ViewModel())
}
