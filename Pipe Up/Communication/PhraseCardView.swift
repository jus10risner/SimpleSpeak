//
//  PhraseCardView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/11/24.
//

import SwiftUI

struct PhraseCardView: View {
    @EnvironmentObject var vm: ViewModel
    @FetchRequest(sortDescriptors: []) var savedPhrases: FetchedResults<SavedPhrase>
    
    @Binding var selectedCategory: PhraseCategory?
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 5)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(filteredPhrases, id: \.self) { phrase in
                    Button {
                        vm.speak(phrase.text)
                    } label: {
                        Group {
                            if let label = phrase.label {
                                Text(label)
                            } else {
                                Text(phrase.text)
                            }
                        }
                        .foregroundStyle(Color.primary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(20)
                        .frame(height: 100)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
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
    PhraseCardView(selectedCategory: .constant(nil))
        .environmentObject(ViewModel())
}
