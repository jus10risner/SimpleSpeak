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
    
    // Used for navigation
    enum Destination: Hashable {
        case recents
        case category(PhraseCategory)
    }
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(value: Destination.recents) {
                    Label {
                        Text("Recents")
                    } icon: {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(Color.secondary)
                    }
                }
                
                ForEach(categories) { category in
                    NavigationLink(value: Destination.category(category)) {
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
                    Label("Add Category", systemImage: "plus")
                }
            }
            .listRowSpacing(vm.listRowSpacing)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Categories")
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .recents:
                    SavedPhrasesListView()
                case .category(let category):
                    SavedPhrasesListView(category: category)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "xmark")
                            .labelStyle(.adaptive)
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    if vm.allDefaultCategoriesAdded(categories: categories) == false {
                        Button {
                            showingDefaultCategoriesSelector = true
                        } label: {
                            Label("Add Default Categories", systemImage: "rectangle.stack.badge.plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $isAddingCategory, content: {
                AddEditCategoryView()
            })
            .sheet(isPresented: $showingDefaultCategoriesSelector, content: {
                DefaultCategoriesSelectorView(showHeader: false)
                    .presentationDetents(UIDevice.current.userInterfaceIdiom == .pad ? [.large] : [.medium])
            })
            .alert("Duplicate Category", isPresented: $showingDuplicateCategoryAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("This category title already exists. Please select a different title.")
            }
        }
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
    return CategoriesListView()
        .environmentObject(ViewModel())
}
