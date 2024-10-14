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
    
    @FetchRequest var savedPhrases: FetchedResults<SavedPhrase>
    
    var category: PhraseCategory?
    
    @State private var showingAddPhrase = false
    @State private var showingDeleteAlert = false
    @State private var showingEditCategory = false
    
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
            if category == nil {
                Section {
                    recentsPicker
                }
            }
            
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
                vm.deletePhrase(at: indexSet, from: savedPhrases, in: context)
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
                }
            }
            
            if category?.title != "Favorites" && category != nil {
                ToolbarTitleMenu {
                    categoryMenu
                }
            }
        }
        .onChange(of: vm.numberOfRecents) { _ in
            withAnimation {
                updateRecentsList()
            }
        }
        .overlay {
            if savedPhrases.count == 0 {
                emptyPhraseList
            }
        }
        .sheet(isPresented: $showingAddPhrase) {
            AddSavedPhraseView(category: category)
        }
        .sheet(isPresented: $showingEditCategory) {
            if let category {
                EditCategoryView(selectedCategory: category)
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
    
    private var recentsPicker: some View {
        let numberToKeep = [10, 50, 100]
        
        return Picker(selection: $vm.numberOfRecents) {
            ForEach(numberToKeep, id: \.self) {
                Text($0.description)
            }
        } label: {
            Label("Recents to Keep", systemImage: "clock.arrow.circlepath")
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
    
    private var emptyPhraseList: some View {
        ZStack {
            Color(.systemGroupedBackground)
            
            VStack(spacing: 10) {
                Image(systemName: category?.symbolName ?? "clock.arrow.circlepath")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 5) {
                    Text(category == nil ? "No Recents" : "No Phrases")
                        .font(.title2.bold())
                    
                    Text(category == nil ? "" : "Tap the plus button to add a phrase.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    func updateRecentsList() {
        let recentsList = savedPhrases.filter { $0.category == nil }
        guard recentsList.count > vm.numberOfRecents else { return }
        
        for index in recentsList.indices {
            if index > vm.numberOfRecents - 1 {
                context.delete(recentsList[index])
            }
        }
        
        try? context.save()
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
