//
//  PhraseCardView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 7/11/24.
//

import SwiftUI

struct PhraseCardView: View {
    @EnvironmentObject var vm: ViewModel
    @FetchRequest var savedPhrases: FetchedResults<SavedPhrase>
    
    let category: PhraseCategory
    @Binding var showingAddPhrase: Bool
    @Binding var phraseToEdit: SavedPhrase?
    
    // Custom init, so I can pass in the category property as a predicate
    init(category: PhraseCategory, showingAddPhrase: Binding<Bool>, phraseToEdit: Binding<SavedPhrase?>) {
        self.category = category
        self._showingAddPhrase = showingAddPhrase
        self._phraseToEdit = phraseToEdit
        let predicate = NSPredicate(format: "category == %@", category)
        
        self._savedPhrases = FetchRequest(entity: SavedPhrase.entity(), sortDescriptors: [
            NSSortDescriptor(
                keyPath: \SavedPhrase.displayOrder,
                ascending: true)
        ], predicate: predicate, animation: .easeInOut)
    }
    
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: CGFloat(vm.cellWidth.rawValue)), spacing: 5)]
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(savedPhrases) { phrase in
                    CardButton(phraseToEdit: $phraseToEdit, phrase: phrase)
                }
                
                addPhraseButton
            }
            .padding()
            .animation(.default, value: category.phrases?.count)
        }
    }
    
    private var addPhraseButton: some View {
        Button {
            showingAddPhrase = true
        } label: {
            Label("Add Phrase", systemImage: "plus")
                .labelStyle(.iconOnly)
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .overlay {
                    RoundedRectangle(cornerRadius: vm.cornerRadius)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [7]))
                        .foregroundStyle(Color.secondary)
                        .opacity(0.5)
                }
        }
    }
}

#Preview {
    let context = DataController.preview.container.viewContext
    let category = PhraseCategory(context: context)
    category.title = "Favorites"
    
    return PhraseCardView(category: category, showingAddPhrase: .constant(false), phraseToEdit: .constant(nil))
        .environmentObject(ViewModel())
}
