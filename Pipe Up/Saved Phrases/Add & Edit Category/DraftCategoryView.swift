//
//  DraftCategoryView.swift
//  Pipe Up
//
//  Created by Justin Risner on 9/19/24.
//

import SwiftUI

struct DraftCategoryView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @ObservedObject var draftCategory: DraftCategory
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.title_, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    
    let isEditing: Bool
    let selectedCategory: PhraseCategory?
    
    @State private var showingDeleteAlert = false
    @State private var showingDuplicateAlert = false
    @State private var hasChanges = false

    @FocusState var isInputActive: Bool
    
    var body: some View {
        Form {
            TextField("Category Name", text: $draftCategory.title)
                .focused($isInputActive)
                .onAppear {
                    if isEditing == false {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                            isInputActive = true
                        }
                    }
                }
            
            Section {
                symbolGrid
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: draftCategoryData) { _ in
            hasChanges = true
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    if canSaveCategory {
                        saveCategory()
                    } else {
                        showingDuplicateAlert = true
                    }
                }
                .disabled(hasChanges && draftCategory.canBeSaved ? false : true)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Duplicate Category", isPresented: $showingDuplicateAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This category name already exists. Please select a different name.")
        }
    }
    
    // Used to detect changes in draftCategory's published properties, to determine whether the Save button is enabled
    private var draftCategoryData: [String?] {
        return [draftCategory.title, draftCategory.symbolName]
    }
    
    private var canSaveCategory: Bool {
        if categories.contains(where: { $0.title == draftCategory.title && $0.id != draftCategory.id }) {
            return false
        } else {
            return true
        }
    }
    
    private var symbolGrid: some View {
        let columns = [GridItem(.adaptive(minimum: 50), spacing: 5)]
        
        return LazyVGrid(columns: columns, spacing: 20) {
            ForEach(SelectableSymbols.allCases, id: \.self) { symbol in
                Image(systemName: symbol.rawValue)
                    .font(.title2)
                    .foregroundStyle(draftCategory.symbolName == symbol.rawValue ? Color(.defaultAccent) : Color.secondary)
                    .onTapGesture { draftCategory.symbolName = symbol.rawValue }
            }
        }
        .padding(.vertical)
    }
    
    func saveCategory() {
        if isEditing {
            selectedCategory?.update(draftCategory: draftCategory)
        } else {
            addCategory()
        }
        
        dismiss()
    }
    
    // Adds a new category
    func addCategory() {
        if categories.contains(where: { $0.title == draftCategory.title || draftCategory.title == "Recents" }) {
            showingDuplicateAlert = true
        } else {
            let newCategory = PhraseCategory(context: context)
            newCategory.id = UUID()
            newCategory.title = draftCategory.title
            newCategory.symbolName = draftCategory.symbolName
            newCategory.displayOrder = (categories.last?.displayOrder ?? 0) + 1
        
            try? context.save()
        }
    }
}

#Preview {
    DraftCategoryView(draftCategory: DraftCategory(), isEditing: false, selectedCategory: nil)
}

private enum SelectableSymbols: String, CaseIterable {
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
