//
//  AddEditCategoryView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 9/19/24.
//

import SwiftUI

struct AddEditCategoryView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @StateObject var draftCategory: DraftCategory
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.displayOrder, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    
    let selectedCategory: PhraseCategory?
    let onDelete: (() -> Void)?
    
    init(selectedCategory: PhraseCategory? = nil, onDelete: (() -> Void)? = nil) {
        self.selectedCategory = selectedCategory
        self.onDelete = onDelete
        
        _draftCategory = StateObject(wrappedValue: DraftCategory(phraseCategory: selectedCategory))
    }
    
    @State private var showingDeleteAlert = false
    @State private var showingDuplicateAlert = false
    @State private var hasChanges = false

    @FocusState var isInputActive: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Category Name", text: $draftCategory.title)
                    .focused($isInputActive)
                    .onAppear {
                        if selectedCategory == nil {
                            DispatchQueue.main.async {
                                isInputActive = true
                            }
                        }
                    }
                
                Section {
                    // This prevents the app from crashing when rotating the phone from portrait to landscape orientation. The app gets stuck in a recursive layout loop, unable to rearrange the symbols, without this
                    ViewThatFits {
                        symbolGrid
                        
                        symbolGrid
                    }
                }
                
                if selectedCategory != nil {
                    Button("Delete Category", role: .destructive) {
                        showingDeleteAlert = true
                    }
                }
            }
            .navigationTitle(selectedCategory == nil ? "New Category" : "Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: draftCategoryData) {
                hasChanges = true
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if canSaveCategory {
                            saveCategory()
                        } else {
                            showingDuplicateAlert = true
                        }
                    } label: {
                        Label("Save", systemImage: "checkmark")
                            .labelStyle(.adaptive)
                    }
                    .disabled(hasChanges && draftCategory.canBeSaved ? false : true)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                            .labelStyle(.adaptive)
                    }
                }
            }
            .alert("Duplicate Category", isPresented: $showingDuplicateAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("This category name already exists. Please select a different name.")
            }
            .alert("Delete Category", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    guard let selectedCategory else { return }
                    
                    deleteCategory(selectedCategory)
                }
                
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Delete this category and all associated phrases?\nThis cannot be undone.")
            }
        }
    }
    
    // Used to detect changes in draftCategory's published properties, to determine whether the Save button is enabled
    private var draftCategoryData: [String?] {
        return [draftCategory.title, draftCategory.symbolName]
    }
    
    private var canSaveCategory: Bool {
        !categories.contains(where: { $0.title.normalized == draftCategory.title.normalized && $0.id != draftCategory.id })
    }
    
    private var symbolGrid: some View {
        let columns = [GridItem(.adaptive(minimum: 45, maximum: 50), spacing: 15)]
        
        return LazyVGrid(columns: columns, spacing: 5) {
            ForEach(SelectableSymbols.allCases, id: \.self) { symbol in
                Image(systemName: symbol.rawValue)
                    .font(.title2)
                    .foregroundStyle(draftCategory.symbolName == symbol.rawValue ? Color(.accent) : Color.secondary)
                    .frame(width: 45, height: 45)
                    .background {
                        if draftCategory.symbolName == symbol.rawValue {
                            Circle()
                                .stroke(Color(.accent), lineWidth: 3)
                        }
                    }
                    .onTapGesture { draftCategory.symbolName = symbol.rawValue }
            }
        }
        .padding(.vertical)
    }
    
    private func saveCategory() {
        if let selectedCategory {
            selectedCategory.update(draftCategory: draftCategory)
        } else {
            addCategory()
        }
        
        dismiss()
    }
    
    private func deleteCategory(_ category: PhraseCategory) {
        // Delete any phrases first, to prevent unexpected behavior
        if let phrases = category.phrases as? Set<SavedPhrase> {
            for phrase in phrases {
                context.delete(phrase)
            }
        }
        
        // After a brief pause, delete the category itself, then save
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            context.delete(category)
            
            try? context.save()
        }
        
        onDelete?() // Triggers dismissal of the saved phrases list
        dismiss()
    }
    
    // Adds a new category
    private func addCategory() {
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
    AddEditCategoryView()
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
