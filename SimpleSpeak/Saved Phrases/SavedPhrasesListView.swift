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
                } footer: {
                    Text("Max number of recent phrases to save; oldest phrases will be deleted as new ones are added.")
                }
            }
            
            Section {
                ForEach(savedPhrases) { phrase in
                    NavigationLink {
                        EditSavedPhraseView(category: category, savedPhrase: phrase, showCancelButton: false)
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
        .navigationTitle(category?.title ?? "Recents")
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
            ToolbarItemGroup(placement: .topBarTrailing) {
                if category != nil {
                    Button {
                        showingAddPhrase = true
                    } label: {
                        Label("Add New Phrase", systemImage: "plus.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title2)
                    }
                    .buttonStyle(.borderless)
                }
            }
            
            if category != nil {
                ToolbarItem(placement: .principal) {
                    Menu {
                        categoryMenu
                    } label: {
                        HStack(spacing: 3) {
                            Text(category?.title ?? "Recents")
                                .font(.headline)
                                .foregroundStyle(Color.primary)
                            
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.caption)
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                    .popover(isPresented: $onboarding.isShowingManageCategoryTip) {
                        PopoverTipView(symbolName: "pencil", title: "Modify Category", text: "Tap the category name to make changes or delete.")
                            .onDisappear { onboarding.currentStep = .complete }
                        
                    }
                    .confirmationDialog("Delete Category", isPresented: $showingDeleteAlert) {
                        Button("Delete", role: .destructive) {
                            guard let category else { return }
                            
                            deleteCategory(category)
                        }
                        
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Delete this category and all associated phrases?\nThis cannot be undone.")
                    }
                }
            }
        }
        .onChange(of: vm.numberOfRecents) { _ in
            withAnimation {
                updateRecentsList()
            }
        }
        .overlay {
            // The category.symbolName check prevents a "no symbol found" error when deleting a category
            if savedPhrases.count == 0 && category?.symbolName != "" {
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
    }
    
    private var recentsPicker: some View {
        let numberToKeep = [10, 50, 100]
        
        return Picker("Recents to Keep", selection: $vm.numberOfRecents) {
            ForEach(numberToKeep, id: \.self) {
                Text($0.description)
            }
        }
    }
    
    private var categoryMenu: some View {
        Group {
            Button {
                showingEditCategory = true
            } label: {
                Label("Edit Category", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete Category", systemImage: "trash")
            }
        }
    }
    
    private var emptyPhraseList: some View {
        ZStack {
            Color.clear
            
            VStack(spacing: 10) {
                Image(systemName: category?.symbolName ?? "clock.arrow.circlepath")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                
                VStack(spacing: 5) {
                    Text(category == nil ? "No Recents" : "No Phrases")
                        .font(.title2.bold())
                    
                    Text(category == nil ? "Recently-typed phrases will appear here." : "Tap the plus button to add a phrase.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilitySortPriority(category == nil ? -1 : 0)
        }
        .ignoresSafeArea()
    }
    
    func deleteCategory(_ category: PhraseCategory) {
        // Delete any phrases first, to prevent unexpected behavior
        if let phrases = category.phrases as? Set<SavedPhrase> {
            for phrase in phrases {
                context.delete(phrase)
            }
        }
        
        // After a brief pause, delete the category itself, then save
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            context.delete(category)
            
            try? context.save()
        }
        
        dismiss()
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
        .environmentObject(OnboardingManager())
        .environmentObject(ViewModel())
}
