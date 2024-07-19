//
//  SavedPhrasesListView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/11/24.
//

import SwiftUI

struct SavedPhrasesListView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var vm: ViewModel
    
    @FetchRequest(sortDescriptors: []) var categories: FetchedResults<PhraseCategory>
    @FetchRequest var savedPhrases: FetchedResults<SavedPhrase>
    
    let category: PhraseCategory?
    
    @State private var showingAddPhrase = false
    
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
            ForEach(savedPhrases, id: \.id) { phrase in
                Button {
                    vm.speak(phrase.text)
                } label: {
                    if let label = phrase.label {
//                        Text("\(label)(\(phrase.displayOrder))")
                        Text(label)
                    } else {
//                        Text("\(phrase.text)(\(phrase.displayOrder))")
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
//            .onDelete(perform: { indexSet in
//                vm.deletePhrase(at: indexSet, from: savedPhrases)
//            })
            
            // TODO: Remove this, when finished testing
            #if DEBUG
            Button("Clear Phrases") {
                for item in savedPhrases {
                    context.delete(item)
                    try? context.save()
                }
            }
            #endif
        }
        .listRowSpacing(vm.listRowSpacing)
        .toolbar {
            if categories.count != 0 {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddPhrase = true
                    } label: {
                        Label("Add New Phrase", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddPhrase) {
            AddSavedPhraseView(category: category)
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
