//
//  CategoriesListView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/19/24.
//

import SwiftUI

struct CategoriesListView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var vm: ViewModel
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.title_, ascending: true)], animation: .easeInOut) var categories: FetchedResults<PhraseCategory>
    
    @State private var showingAddPhrase = false
    @State private var isAddingCategory = false
    @State private var categoryTitle = ""
    @State private var showingDuplicateCategoryAlert = false
    
    var body: some View {
        NavigationStack {
            categoryList
                .navigationTitle("Phrases")
                .listRowSpacing(vm.listRowSpacing)
//                .scrollContentBackground(.hidden)
//                .background(Color(.systemGroupedBackground))
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    if categories.count == 0 {
                        addSavedCategory()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isAddingCategory = true
                        } label: {
                            Label("Add New Category", systemImage: "plus.circle.fill")
                        }
                    }
                }
                .alert("Add Category", isPresented: $isAddingCategory) {
                    TextField("Category Title", text: $categoryTitle)
                    Button("Save") {
                        addCategory()
                        categoryTitle = ""
                    }
                    Button("Cancel", role: .cancel) { categoryTitle = "" }
                }
                .alert("Duplicate Category", isPresented: $showingDuplicateCategoryAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("This category title already exists. Please select a different title.")
                }
        }
    }
    
    // List of categories, with navigation links to their respective phrases
    // ZStacks and clear colors were added, due to jumpy navigation behavior on iOS 16
    private var categoryList: some View {
        List {
            ZStack {
                Color.clear
                NavigationLink("Recent Phrases") {
                    SavedPhrasesListView(category: nil)
                }
            }
            
            ForEach(categories) { category in
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
    }
    
    // Adds a default "Saved" category
    func addSavedCategory() {
        let newCategory = PhraseCategory(context: context)
        newCategory.id = UUID()
        newCategory.title = "Saved"
    
        try? context.save()
    }
    
    // Adds a new category
    func addCategory() {
        if categories.contains(where: { $0.title == categoryTitle }) {
            showingDuplicateCategoryAlert = true
        } else {
            let newCategory = PhraseCategory(context: context)
            newCategory.id = UUID()
            newCategory.title = categoryTitle
        
            try? context.save()
        }
    }
}

#Preview {
    let controller = DataController(inMemory: true)
    let context = controller.container.viewContext
    
    return CategoriesListView()
        .environment(\.managedObjectContext, context)
        .environmentObject(ViewModel())
}
