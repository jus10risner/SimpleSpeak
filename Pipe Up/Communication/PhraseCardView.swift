//
//  PhraseCardView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/11/24.
//

import SwiftUI

struct PhraseCardView: View {
    @Environment(\.managedObjectContext) var context
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
    
//    let columns = [GridItem(.adaptive(minimum: 150), spacing: 5)]
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: CGFloat(vm.cellWidth.rawValue)), spacing: 5)]
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(savedPhrases) { phrase in
                    CardButton(phraseToEdit: $phraseToEdit, phrase: phrase)
                    
//                    Button {
////                        haptics.buttonTapped()
//                        vm.cancelAndSpeak(phrase)
////                    Menu {
////                        Button {
////                            phraseToEdit = phrase
////                        } label: {
////                            Label("Edit Phrase", systemImage: "pencil")
////                        }
//                        
////                        Button(role: .destructive) {
////                            context.delete(phrase)
////                            try? context.save()
////                        } label: {
////                            Label("Delete Phrase", systemImage: "trash")
////                        }
//                    } label: {
//                        ZStack {
//                            Group {
//                                if phrase.label != "" {
//                                    Text(phrase.label)
//                                } else {
//                                    Text(phrase.text)
//                                }
//                            }
//                            .font(.headline)
//                            .minimumScaleFactor(0.9)
//                            .frame(maxWidth: .infinity)
//                            .multilineTextAlignment(.center)
//                            .padding()
//                            .frame(height: 100)
//                        }
//                        .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
//                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: vm.cornerRadius))
//                    }
//                    .contextMenu {
//                        Button {
//                            phraseToEdit = phrase
//                        } label: {
//                            Label("Edit Phrase", systemImage: "pencil")
//                        }
//                    }
//                    .buttonStyle(.plain)
                }
                
                addPhraseButton
            }
//            .padding([.horizontal, .bottom])
//            .padding(.top, 5)
            .padding()
            
            // Allows phrases to scroll up to avoid hovering buttons on CommunicationView
            Color.clear.frame(height: UIScreen.main.bounds.height * 0.1)
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
