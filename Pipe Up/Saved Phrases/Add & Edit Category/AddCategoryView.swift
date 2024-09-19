//
//  AddCategoryView.swift
//  Pipe Up
//
//  Created by Justin Risner on 9/19/24.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @StateObject var draftCategory: DraftCategory
    
    init() {
        _draftCategory = StateObject(wrappedValue: DraftCategory())
    }
    
//    @FetchRequest(sortDescriptors: []) var categories: FetchedResults<PhraseCategory>
    
//    @State private var selectedSymbol: SelectableSymbols = .bookmark
//    @State private var categoryTitle = ""
//    @State private var showingDuplicateCategoryAlert = false
//    
//    @FocusState var isInputActive: Bool
    
    var body: some View {
        NavigationStack {
            DraftCategoryView(draftCategory: draftCategory, isEditing: false, selectedCategory: nil)
                .navigationTitle("Add Category")
                .navigationBarTitleDisplayMode(.inline)
//                .onAppear {
//                    draftPhrase.category = category
//                }
//                .toolbar {
//                    ToolbarItem(placement: .topBarLeading) {
//                        Button("Cancel") {
//                            dismiss()
//                        }
//                    }
//                }
            
//            Form {
//                TextField("Category Name", text: $categoryTitle)
//                    .focused($isInputActive)
//                    .onAppear {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
//                            isInputActive = true
//                        }
//                    }
//                
//                symbolGrid
//            }
//            .navigationTitle("Add Category")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Save") {
//                        addCategory()
//                        dismiss()
//                    }
//                    .disabled(categoryTitle.isEmpty ? true : false)
//                }
//                
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//            }
//            .alert("Duplicate Category", isPresented: $showingDuplicateCategoryAlert) {
//                Button("OK", role: .cancel) { }
//            } message: {
//                Text("This category title already exists. Please select a different title.")
//            }
        }
    }
    
//    private var symbolGrid: some View {
//        let columns = [GridItem(.adaptive(minimum: 50), spacing: 5)]
//        
//        return LazyVGrid(columns: columns, spacing: 20) {
//            ForEach(SelectableSymbols.allCases, id: \.self) { symbol in
//                Image(systemName: symbol.rawValue)
//                    .font(.title2)
//                    .foregroundStyle(selectedSymbol == symbol ? Color(.defaultAccent) : Color.secondary)
//                    .onTapGesture {
//                        selectedSymbol = symbol
//                    }
//            }
//        }
//    }
//    
//    // Adds a new category
//    func addCategory() {
//        if categories.contains(where: { $0.title == categoryTitle || categoryTitle == "Recents" }) {
//            showingDuplicateCategoryAlert = true
//        } else {
//            let newCategory = PhraseCategory(context: context)
//            newCategory.id = UUID()
//            newCategory.title = categoryTitle
//            newCategory.symbolName = selectedSymbol.rawValue
//            newCategory.displayOrder = (categories.last?.displayOrder ?? 0) + 1
//        
//            try? context.save()
//        }
//    }
}

#Preview {
    AddCategoryView()
}

enum SelectableSymbols: String, CaseIterable {
    case
    bookmark = "bookmark.fill",
    book = "book.fill",
    books = "books.vertical.fill",
    lanyard = "lanyardcard.fill",
    person = "figure.arms.open",
    twoPeople = "figure.2.arms.open",
    parentsAndChild = "figure.2.and.child.holdinghands",
    parentAndChild = "figure.and.child.holdinghands",
    sun = "sun.max.fill",
    zzz,
    moon = "moon.fill",
    hear = "heart.fill",
    star = "star.fill",
    messageBubble = "bubble.right.fill",
    phone = "phone.fill",
    creditCard = "creditcard.fill",
    puzzlePiece = "puzzlepiece.fill",
    house = "house.fill",
    bed = "bed.double.fill",
    desktopcomputer,
    airplane,
    car = "car.fill",
    train = "train.side.front.car",
    bandage = "bandage.fill",
    cross = "cross.fill",
    dog = "dog.fill",
    cat = "cat.fill",
    lizard = "lizard.fill",
    bird = "bird.fill",
    fish = "fish.fill",
    pawPrint = "pawprint.fill",
    leaf = "leaf.fill",
    handWave = "hand.wave.fill",
    gameController = "gamecontroller.fill",
    cake = "birthday.cake.fill",
    utensils = "fork.knife",
    gift = "gift.fill",
    bankNote = "banknote.fill",
    number
}
