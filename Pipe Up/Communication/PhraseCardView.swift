//
//  PhraseCardView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/11/24.
//

import SwiftUI

struct PhraseCardView: View {
    @EnvironmentObject var vm: ViewModel
    @FetchRequest var savedPhrases: FetchedResults<SavedPhrase>
    
    let category: PhraseCategory
    @Binding var showingAddPhrase: Bool
    
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
                    Button {
                        if vm.synthesizerState != .inactive {
                            vm.cancelSpeaking()
                        }
                        
                        vm.speak(phrase.text)
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
                    }
                    .buttonStyle(.plain)
                }
                
                addPhraseButton
            }
            .padding([.horizontal, .bottom])
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
    
    return PhraseCardView(category: category, showingAddPhrase: .constant(false))
        .environmentObject(ViewModel())
}
