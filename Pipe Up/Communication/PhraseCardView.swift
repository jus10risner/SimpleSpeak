//
//  PhraseCardView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/11/24.
//

import SwiftUI

struct PhraseCardView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: ViewModel
    @FetchRequest var savedPhrases: FetchedResults<SavedPhrase>
    
    let category: PhraseCategory
    @Binding var showingAddPhrase: Bool
    
    @State private var phraseToEdit: SavedPhrase?
    
    // Custom init, so I can pass in the category property as a predicate
    init(category: PhraseCategory, showingAddPhrase: Binding<Bool>) {
        self.category = category
        self._showingAddPhrase = showingAddPhrase
        let predicate = NSPredicate(format: "category == %@", category)
        
        self._savedPhrases = FetchRequest(entity: SavedPhrase.entity(), sortDescriptors: [
            NSSortDescriptor(
                keyPath: \SavedPhrase.displayOrder,
                ascending: true)
        ], predicate: predicate, animation: .easeInOut)
    }
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 5)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(savedPhrases) { phrase in
                    Menu {
                        Button {
                            phraseToEdit = phrase
                        } label: {
                            Label("Edit Phrase", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            context.delete(phrase)
                            try? context.save()
                        } label: {
                            Label("Delete Phrase", systemImage: "trash")
                        }
                    } label: {
                        ZStack {
                            Group {
                                if phrase.label != "" {
                                    Text(phrase.label)
                                } else {
                                    Text(phrase.text)
                                }
                            }
                            .font(.headline)
                            .minimumScaleFactor(0.9)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(height: 100)
                        }
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
                    } primaryAction: {
                        // Makes menu function as a simple button, unless longPressGesture is used
                        speakPhrase(phrase)
                    }
                    .buttonStyle(.plain)
                }
                
                addPhraseButton
            }
            .padding([.horizontal, .bottom])
            .sheet(item: $phraseToEdit, content: { phrase in
                EditSavedPhraseView(category: category, savedPhrase: phrase, showCancelButton: true)
            })
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
    
    // Speaks the selected phrase
    func speakPhrase(_ phrase: SavedPhrase) {
        if vm.synthesizerState != .inactive {
            vm.cancelSpeaking()
        }
        
        vm.speak(phrase.text)
    }
}

#Preview {
    let context = DataController.preview.container.viewContext
    let category = PhraseCategory(context: context)
    category.title = "Favorites"
    
    return PhraseCardView(category: category, showingAddPhrase: .constant(false))
        .environmentObject(ViewModel())
}
