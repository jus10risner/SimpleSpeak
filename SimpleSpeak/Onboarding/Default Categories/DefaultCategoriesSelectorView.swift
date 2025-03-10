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
    let shouldShowHeader: Bool
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    createDefaultCategory(name: "Basics", symbolName: "circle.fill", description: "Phrases for everyday conversation", phrases: defaultCategories.basics)
                    
                    createDefaultCategory(name: "Feelings", symbolName: "heart.fill", description: "Express emotions", phrases: defaultCategories.feelings)
                    
                    createDefaultCategory(name: "Health", symbolName: "stethoscope", description: "Discuss medical concerns and needs", phrases: defaultCategories.health)
                    
                    createDefaultCategory(name: "Interactions", symbolName: "bubble.left.and.bubble.right.fill", description: "Greetings, conversations, and farewells", phrases: defaultCategories.interactions)
                    
                    createDefaultCategory(name: "Requests", symbolName: "hand.raised.fill", description: "Communicate needs and preferences", phrases: defaultCategories.requests)
                } header: {
                    if shouldShowHeader {
                        Text("You can add these later in **Manage Categories**")
                    }
                }
                .textCase(nil)
            }
            .listRowSpacing(5)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .animation(.easeInOut, value: categories.count)
            .navigationTitle("Default Categories")
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
        let defaultCategoryTitles = ["basics", "feelings", "health", "interactions", "requests"]
        
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
    DefaultCategoriesSelectorView(shouldShowHeader: true)
}
