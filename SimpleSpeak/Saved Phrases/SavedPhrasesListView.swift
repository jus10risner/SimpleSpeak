//
//  SavedPhrasesListView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 7/11/24.
//

import SwiftUI

struct SavedPhrasesListView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var onboarding: OnboardingManager
    @EnvironmentObject var vm: ViewModel
    
    @FetchRequest var savedPhrases: FetchedResults<SavedPhrase>
    
    var category: PhraseCategory?
    
    @State private var showingAddPhrase = false
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
            headerSection
            
            if category == nil {
                Section {
                    recentsPicker
                } footer: {
                    Text("Max number of recent phrases to save; oldest phrases will be deleted as new ones are added.")
                }
            } else if savedPhrases.count == 0 && category?.symbolName != "" {
                // category?.symbolName check prevents a "no symbol found" error when deleting a category
                Text("Tap the plus button to add a phrase.")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity)
            }
            
            Section {
                ForEach(savedPhrases) { phrase in
                    NavigationLink {
                        AddEditPhraseView(category: category, savedPhrase: phrase)
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
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .allowsHitTesting(onboarding.isShowingManageCategoryTip ? false : true)
        .onAppear {
            if onboarding.currentStep == .manageCategory && category != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    onboarding.isShowingManageCategoryTip = true
                }
            }
        }
        .toolbar {
            ToolbarItem {
                if category != nil {
                    Button {
                        showingAddPhrase = true
                    } label: {
                        Label("Add New Phrase", systemImage: "plus")
                    }
                }
            }
        }
        .onChange(of: vm.numberOfRecents) {
            withAnimation {
                updateRecentsList()
            }
        }
        .sheet(isPresented: $showingAddPhrase) {
            AddEditPhraseView(category: category, showCancelButton: true)
        }
        .sheet(isPresented: $showingEditCategory) {
            if let category {
                AddEditCategoryView(selectedCategory: category, onDelete: { dismiss() })
            }
        }
    }
    
    // The symbol, name, and Edit button for the displayed category
    private var headerSection: some View {
        Section {
            VStack(spacing: 10) {
                Image(systemName: category?.symbolName ?? "clock.arrow.trianglehead.counterclockwise.rotate.90")
                    .font(.largeTitle)
                    .foregroundStyle(Color(.defaultAccent))
                    .padding()
                    .background(Color(.tertiarySystemBackground), in: Circle())
                    .accessibilityHidden(true)
                
                VStack(spacing: 0) {
                    Text(category?.title ?? "Recents")
                        .font(.title3.bold())
                    
                    if category != nil {
                        Button("Edit") {
                            showingEditCategory = true
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    // Picker that lets users specify how many recent phrases to keep
    private var recentsPicker: some View {
        let numberToKeep = [10, 50, 100]
        
        return Picker("Recents to Keep", selection: $vm.numberOfRecents) {
            ForEach(numberToKeep, id: \.self) {
                Text($0.description)
            }
        }
    }
    
    // Removes any recent phrases that exceed the specified number to keep, if necessary
    private func updateRecentsList() {
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
    private func move(from source: IndexSet, to destination: Int) {
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
        .environmentObject(OnboardingManager())
        .environmentObject(ViewModel())
}
