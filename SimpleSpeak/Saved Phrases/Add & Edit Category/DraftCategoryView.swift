//
//  DraftCategoryView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 9/19/24.
//

import SwiftUI

struct DraftCategoryView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @ObservedObject var draftCategory: DraftCategory
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.displayOrder, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    
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
            
            Section("Select a symbol to represent this category.") {
                // This prevents the app from crashing when rotating the phone from portrait to landscape orientation. The app gets stuck in a recursive layout loop, unable to rearrange the symbols, without this
                ViewThatFits {
                    symbolGrid
                    
                    symbolGrid
                }
            }
            .textCase(nil)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
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
        if categories.contains(where: { $0.title.normalized == draftCategory.title.normalized && $0.id != draftCategory.id }) {
            return false
        } else {
            return true
        }
    }
    
    private var symbolGrid: some View {
        let columns = [GridItem(.adaptive(minimum: 50))]
        
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
    utensils = "fork.knife",
    books = "books.vertical.fill",
    lanyard = "lanyardcard.fill",
    columnBuilding = "building.columns.fill",
    buildings = "building.2.fill",
    person = "figure.arms.open",
    twoPeople = "figure.2.arms.open",
    parentsAndChild = "figure.2.and.child.holdinghands",
    parentAndChild = "figure.and.child.holdinghands",
    handWave = "hand.wave.fill",
    handRaised = "hand.raised.fill",
    overlappingBubbles = "bubble.left.and.bubble.right.fill",
    speechBubble = "bubble.left.fill",
    questionBubble = "questionmark.bubble.fill",
    phone = "phone.fill",
    bankNote = "banknote.fill",
    creditCard = "creditcard.fill",
    cart = "cart.fill",
    dumbbell = "dumbbell.fill",
    hammer = "hammer.fill",
    house = "house.fill",
    bed = "bed.double.fill",
    car = "car.fill",
    airplane,
    tram = "tram.fill",
    stethoscope = "stethoscope",
    pills = "pills.fill",
    pawPrint = "pawprint.fill",
    leaf = "leaf.fill",
    gameController = "gamecontroller.fill",
    cake = "birthday.cake.fill",
    gift = "gift.fill",
    palette = "paintpalette.fill",
    number,
    sun = "sun.max.fill",
    moon = "moon.fill",
    star = "star.fill",
    circle = "circle.fill",
    heart = "heart.fill"
}
