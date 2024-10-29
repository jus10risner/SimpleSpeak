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
                    addPhraseButton
                }
                
//                if category == nil && filteredPhrases.count == 0 {
//                    Text("No Recents")
//                        .font(.headline)
//                        .foregroundStyle(Color.secondary)
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 100)
//                        .overlay {
//                            RoundedRectangle(cornerRadius: vm.cornerRadius)
//                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [7]))
//                                .foregroundStyle(Color.secondary)
//                                .opacity(0.5)
//                        }
//                } else {
//                    addPhraseButton
//                }
            }
            .padding([.horizontal, .bottom])
        }
//        .overlay {
//            if category == nil && filteredPhrases.count == 0 {
//                VStack(spacing: 15) {
////                    Spacer()
////                    Spacer()
//                    
//                    Image(systemName: "clock.arrow.circlepath")
//                        .font(.system(size: 60))
//                        .foregroundStyle(Color.secondary)
//                        .opacity(0.5)
//                    
//                    Text("No Recent Phrases")
//                        .font(.title3.bold())
////                    Text("Tap to type a phrase")
////
////                    Image(systemName: "arrow.down")
////                        .font(.largeTitle)
////                        .foregroundStyle(Color.secondary)
////
////                    Spacer()
////                    Spacer()
////                    Spacer()
//                }
////                .padding(.bottom, 100)
//            }
//        }
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
    
    // Returns the phrases in the selected category
    private var filteredPhrases: [SavedPhrase] {
        if let category {
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
