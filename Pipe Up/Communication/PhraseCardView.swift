//
//  PhraseCardView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/11/24.
//

import SwiftUI

struct PhraseCardView: View {
    @EnvironmentObject var vm: ViewModel
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \RecentPhrase.timeStamp_, ascending: false)]) var recentPhrases: FetchedResults<RecentPhrase>
    @FetchRequest(sortDescriptors: []) var savedPhrases: FetchedResults<SavedPhrase>
    
    @Binding var selectedCategory: PhraseCategory?
    @Binding var showingRecents: Bool
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 5)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 5) {
                if showingRecents == true { // TODO: Compartmentalize this code, to avoid duplication
                    ForEach(recentPhrases, id: \.self) { phrase in
                        Button {
                            vm.speak(phrase.text)
                        } label: {
                                Text(phrase.text)
                                    .minimumScaleFactor(0.8)
                                    .foregroundStyle(Color.primary)
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                                    .padding(20)
                                    .frame(height: 100)
                                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
                        }
                    }
                } else {
                    ForEach(filteredPhrases, id: \.id) { phrase in
                        Button {
                            vm.speak(phrase.text)
                        } label: {
                            Group {
                                if phrase.label != "" {
                                    Text(phrase.label)
                                } else {
                                    Text(phrase.text)
                                }
                            }
                            .minimumScaleFactor(0.8)
                            .foregroundStyle(Color.primary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(20)
                            .frame(height: 100)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // Returns the phrases in the selected category
    private var filteredPhrases: [SavedPhrase] {
        return savedPhrases.filter({ $0.category == selectedCategory }).sorted(by: { $0.displayOrder < $1.displayOrder })
    }
}

#Preview {
    PhraseCardView(selectedCategory: .constant(nil), showingRecents: .constant(false))
        .environmentObject(ViewModel())
}
