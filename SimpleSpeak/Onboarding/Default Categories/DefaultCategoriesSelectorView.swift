//
//  DefaultCategoriesSelectorView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 2/26/25.
//

import SwiftUI

struct DefaultCategoriesSelectorView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.displayOrder, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    
    let defaultCategories = DefaultCategoryArrays()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    createDefaultCategory(name: "Essentials", symbolName: "bubble.fill", description: "Phrases for everyday conversation", phrases: defaultCategories.essentials)
                
                    createDefaultCategory(name: "Places", symbolName: "map.fill", description: "Names of common locations", phrases: defaultCategories.places)
                
                    createDefaultCategory(name: "Questions", symbolName: "questionmark.bubble.fill", description: "Useful inquiries for daily life", phrases: defaultCategories.questions)
                    
                    createDefaultCategory(name: "Time", symbolName: "clock.fill", description: "Past, present, and future descriptions", phrases: defaultCategories.time)
                }
                .textCase(nil)
            }
            .listRowSpacing(5)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .animation(.easeInOut, value: categories.count)
            .navigationTitle("Add Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onChange(of: categories.count) { _ in
                if allCategoriesAdded {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var allCategoriesAdded: Bool {
        let defaultCategoryTitles = ["essentials", "places", "questions", "time"]
        
        return defaultCategoryTitles.allSatisfy { title in
            categories.contains { $0.title.normalized == title }
        }
    }
    
    func createDefaultCategory(name: String, symbolName: String, description: String, phrases: [String]?) -> some View {
        if !categories.contains(where: { $0.title.normalized == name.normalized }) {
            return AnyView (
                AddDefaultCategoryButton(action: {
                    Task {
                        await addCategory(name: name, symbolName: symbolName, phrases: phrases)
                    }
                }, categoryName: name, description: description)
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    func addCategory(name: String, symbolName: String, phrases: [String]?) async {
        let newCategory = PhraseCategory(context: context)
        newCategory.id = UUID()
        newCategory.title = name
        newCategory.symbolName = symbolName
        newCategory.displayOrder = (categories.last?.displayOrder ?? 0) + 1
    
        if let phrases {
            for (index, phrase) in phrases.enumerated() {
                let newPhrase = SavedPhrase(context: context)
                newPhrase.id = UUID()
                newPhrase.text = phrase
                newPhrase.category = newCategory
                newPhrase.displayOrder = Int64(index)
            }
        }
        
        try? context.save()
    }
}

#Preview {
    DefaultCategoriesSelectorView()
}
