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
    
    let essentials = ["Hello", "Goodbye", "Please", "Thank you", "Sorry", "Excuse me", "Yes", "No", "Maybe", "I don't know", "Help", "Stop"]
    let places = ["Home", "School", "Work", "Store", "Car", "Bathroom", "Park", "Friend’s house", "Doctor", "Hospital"]
    let questions = ["What is this?", "Where is it?", "Can I have this?", "What’s your name?", "What’s this?", "What’s happening?", "When is it?", "How are you?", "Why?", "Can you help me?"]
    let time = ["Now", "Later", "Tomorrow", "Today", "Yesterday", "Wait", "Soon", "I’m ready", "I’m done", "When is it?", "How long?"]
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    createDefaultCategory(name: "Essentials", symbolName: "bubble.fill", description: "Phrases for everyday conversation", phrases: essentials)
                
                    createDefaultCategory(name: "Places", symbolName: "map.fill", description: "Names of common locations", phrases: places)
                
                    createDefaultCategory(name: "Questions", symbolName: "questionmark.bubble.fill", description: "Useful inquiries for everyday life", phrases: questions)
                    
                    createDefaultCategory(name: "Time", symbolName: "clock.fill", description: "Past, present, and future descriptions.", phrases: time)
                }
                .textCase(nil)
            }
            .listRowSpacing(5)
            .animation(.easeInOut, value: categories.count)
            .navigationTitle("Add Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
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
