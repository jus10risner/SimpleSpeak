//
//  PhraseCardView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/11/24.
//

import SwiftUI

struct PhraseCardView: View {
    @EnvironmentObject var vm: ViewModel
    @FetchRequest(sortDescriptors: [], animation: .easeInOut) var savedPhrases: FetchedResults<SavedPhrase>
    
    let category: PhraseCategory?
    @Binding var showingAddPhrase: Bool
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 5)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(filteredPhrases) { phrase in
                    Button {
                        if vm.synthesizerState != .inactive {
                            vm.cancelSpeaking()
                        }
                        
                        vm.speak(phrase.text)
                    } label: {
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
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
                    }
                    .buttonStyle(.plain)
                }
                
                if category != nil {
                    Button {
                        showingAddPhrase = true
                    } label: {
                        Label("Add Phrase", systemImage: "plus")
                            .labelStyle(.iconOnly)
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity)
//                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(height: 100)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
                    }
                }
            }
            .padding()
        }
        .overlay {
            if category?.phrases?.count == 0 {
                EmptyListView(category: category)
            }
        }
    }
    
    // Returns the phrases in the selected category
    private var filteredPhrases: [SavedPhrase] {
        if category != nil {
            return savedPhrases.filter({ $0.category == category }).sorted(by: { $0.displayOrder < $1.displayOrder })
        } else {
            return savedPhrases.filter({ $0.category == category }).sorted(by: { $0.displayOrder > $1.displayOrder })
        }
    }
}

#Preview {
    PhraseCardView(category: nil, showingAddPhrase: .constant(false))
        .environmentObject(ViewModel())
}
