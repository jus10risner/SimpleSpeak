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
    
    @Binding var selectedCategory: PhraseCategory?
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 5)]
    
    var body: some View {
//        ScrollView {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(filteredPhrases) { phrase in
                    Button {
                        if vm.synthesizerState == .speaking {
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
                        .font(.title3.bold())
                        .minimumScaleFactor(0.9)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(height: 100)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
                    }
                    .buttonStyle(.plain)
                }
                
                if selectedCategory != nil {
                    Button {
                        // TODO: Set up Add Phrase
                    } label: {
                        Label("Add Phrase", systemImage: "plus")
//                            .font(.largeTitle)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(height: 100)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
                    }
                }
            }
            .padding()
//            .id(UUID())
//        }
    }
    
    // Returns the phrases in the selected category
    private var filteredPhrases: [SavedPhrase] {
        if selectedCategory != nil {
            return savedPhrases.filter({ $0.category == selectedCategory }).sorted(by: { $0.displayOrder < $1.displayOrder })
        } else {
            return savedPhrases.filter({ $0.category == selectedCategory }).sorted(by: { $0.displayOrder > $1.displayOrder })
        }
    }
}

#Preview {
    PhraseCardView(selectedCategory: .constant(nil))
        .environmentObject(ViewModel())
}
