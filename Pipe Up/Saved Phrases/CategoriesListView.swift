//
//  CategoriesListView.swift
//  Pipe Up
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
    
//    @State private var exportURL: URL?
    
    var body: some View {
        NavigationStack {
            categoryList
                .navigationBarTitleDisplayMode(.inline)
//                .background(Color(.systemGroupedBackground).ignoresSafeArea())
//                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    if categories.count == 0 {
                        addFavoritesCategory()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Manage Phrases")
                            .font(.title2)
                            .fontWeight(.heavy)
                    }
                    
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
            Section {
//                ZStack {
//                    Color.clear
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
//                }
                
                ForEach(categories) { category in
//                    ZStack {
//                        Color.clear
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
//                    }
                }
                .onMove { indices, newOffset in
                    move(from: indices, to: newOffset)
                }
            }
            
            Button {
                isAddingCategory = true
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "plus")
                    
                    Text("Add Category")
                }
                .accessibilityLabel("Add Category")
                .font(.headline)
                .foregroundStyle(Color.white)
//                .frame(maxWidth: .infinity, minHeight: 44)
//                .padding()
            }
            .buttonStyle(.borderedProminent)
//            .background {
//                RoundedRectangle(cornerRadius: 10)
////                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
////                    .foregroundStyle(Color.secondary)
//                    .foregroundStyle(Color(.defaultAccent))
////                    .opacity(0.5)
//            }
//            .frame(maxWidth: .infinity, minHeight: 44)
            .frame(maxWidth: .infinity)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        .listRowSpacing(vm.listRowSpacing)
    }
    
    // Adds a default "Favorites" category
    func addFavoritesCategory() {
        let newCategory = PhraseCategory(context: context)
        newCategory.id = UUID()
        newCategory.title = "Favorites"
        newCategory.symbolName = "star.fill"
        newCategory.displayOrder = 0
    
        try? context.save()
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
//        let categoriesFolderURL = tempDirectoryURL.appendingPathComponent("Pipe Up Data")
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
