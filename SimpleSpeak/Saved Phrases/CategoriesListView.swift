//
//  CategoriesListView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 6/19/24.
//

import SwiftUI

struct CategoriesListView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: ViewModel
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.displayOrder, ascending: true)], animation: .easeInOut) var categories: FetchedResults<PhraseCategory>
    
    @State private var showingAddPhrase = false
    @State private var isAddingCategory = false
    @State private var categoryTitle = ""
    @State private var showingDuplicateCategoryAlert = false
    @State private var showingDefaultCategoriesSelector = false
    
    var body: some View {
        NavigationStack {
            categoryList
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Manage Categories")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Label("Dismiss", systemImage: "xmark.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.title2)
                                .foregroundStyle(Color.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .sheet(isPresented: $isAddingCategory, content: {
                    AddCategoryView()
                })
                .sheet(isPresented: $showingDefaultCategoriesSelector, content: {
                    DefaultCategoriesSelectorView(shouldShowHeader: false)
                        .presentationDetents([.medium])
                })
                .alert("Duplicate Category", isPresented: $showingDuplicateCategoryAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("This category title already exists. Please select a different title.")
                }
                .overlay {
                    VStack {
                        Spacer()
                        
                        if allCategoriesAdded == false {
                            Button("Add Default Categories") { showingDefaultCategoriesSelector = true }
                                .font(.subheadline)
                                .accessibilitySortPriority(-1)
                        }
                    }
                    .padding(.bottom)
                }
        }
    }
    
    private var allCategoriesAdded: Bool {
        let defaultCategoryTitles = ["basics", "feelings", "health", "interactions", "requests"]
        
        return defaultCategoryTitles.allSatisfy { title in
            categories.contains { $0.title.normalized == title }
        }
    }
    
    // List of categories, with navigation links to their respective phrases
    private var categoryList: some View {
        List {
            NavigationLink {
                SavedPhrasesListView(category: nil)
            } label: {
                Label {
                    Text("Recents")
                } icon: {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(Color.secondary)
                }
            }
            
            ForEach(categories) { category in
                NavigationLink {
                    SavedPhrasesListView(category: category)
                        .navigationTitle(category.title)
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    Label {
                        Text(category.title)
                    } icon: {
                        Image(systemName: category.symbolName)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .onMove { indices, newOffset in
                move(from: indices, to: newOffset)
            }
            
            Button {
                isAddingCategory = true
            } label: {
                Label("Add Category", systemImage: "plus.circle.fill")
            }
        }
        .listRowSpacing(vm.listRowSpacing)
    }
    
    // Persists the order of categories, after moving
    func move(from source: IndexSet, to destination: Int) {
        // Make an array of categories from fetched results
        var modifiedCategoryList: [PhraseCategory] = categories.map { $0 }

        // change the order of the categories in the array
        modifiedCategoryList.move(fromOffsets: source, toOffset: destination )

        // update the displayOrder attribute in modifiedCategoryList to
        // persist the new order.
        for index in (0..<modifiedCategoryList.count) {
            modifiedCategoryList[index].displayOrder = Int64(index)
        }
        
        try? context.save()
    }
}

#Preview {
    let controller = DataController(inMemory: true)
    let context = controller.container.viewContext
    
    return CategoriesListView()
        .environment(\.managedObjectContext, context)
        .environmentObject(ViewModel())
}
