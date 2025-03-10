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
    
//    @State private var exportURL: URL?
    
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
                    
//                    ToolbarItemGroup(placement: .topBarLeading) {
//                        Button("Export") {
//                            Task {
//                                let url = exportCategoriesToFolder(categories: Array(categories))
//                                DispatchQueue.main.async {
//                                    exportURL = url
//                                }
//                            }
//                        }
//                        
//                        if let exportURL {
//                            ShareLink(item: exportURL)
//                        }
//                    }
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
            
//            Button {
//                isAddingCategory = true
//            } label: {
//                HStack {
//                    Image(systemName: "plus")
//                    
//                    Text("Category")
//                }
//                .bold()
//            }
//            .accessibilityLabel("Add Category")
//            .frame(maxWidth: .infinity)
//            .listRowInsets(EdgeInsets())
//            .listRowBackground(Color.clear)
            
//        #if DEBUG
//            Button(role: .destructive) {
//                for category in categories {
//                    context.delete(category)
//                }
//                try? context.save()
//            } label: {
//                Label("Delete All Categories", systemImage: "trash.fill")
//            }
//        #endif
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
    
//    func exportCategoriesToFolder(categories: [PhraseCategory]) -> URL? {
//        let fileManager = FileManager.default
//        let tempDirectoryURL = fileManager.temporaryDirectory
//        let categoriesFolderURL = tempDirectoryURL.appendingPathComponent("SimpleSpeak Data")
//        
//        do {
//            // Create the categories folder
//            try fileManager.createDirectory(at: categoriesFolderURL, withIntermediateDirectories: true, attributes: nil)
//            
//            for category in categories {
//                let categoryFolderURL = categoriesFolderURL.appendingPathComponent(category.title)
//                try fileManager.createDirectory(at: categoryFolderURL, withIntermediateDirectories: true, attributes: nil)
//                
//                for phrase in category.phrasesArray {
//                    let phraseFolderURL = categoryFolderURL.appendingPathComponent(phrase.label)
//                    try fileManager.createDirectory(at: phraseFolderURL, withIntermediateDirectories: true, attributes: nil)
//                    
//                    // Save the phrase text with a custom extension
//                    let textFileURL = phraseFolderURL.appendingPathComponent("phrase.pipeupapp")
//                    try phrase.text.write(to: textFileURL, atomically: true, encoding: .utf8)
//                }
//            }
//            
//            // Return the URL of the exported folder
//            return categoriesFolderURL
//        } catch {
//            print("An error occurred while exporting: \(error)")
//            return nil
//        }
//    }
}

#Preview {
    let controller = DataController(inMemory: true)
    let context = controller.container.viewContext
    
    return CategoriesListView()
        .environment(\.managedObjectContext, context)
        .environmentObject(ViewModel())
}
