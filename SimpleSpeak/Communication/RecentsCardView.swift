//
//  RecentsCardView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 11/12/24.
//

import SwiftUI

struct RecentsCardView: View {
    @EnvironmentObject var vm: ViewModel
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SavedPhrase.displayOrder, ascending: false)], predicate: NSPredicate(format: "category == %@", NSNull()), animation: .easeInOut) var recentPhrases: FetchedResults<SavedPhrase>
    
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: CGFloat(vm.cellWidth.rawValue)), spacing: 5)]
    }
    
    @Binding var phraseToEdit: SavedPhrase?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(recentPhrases, id: \.id) { phrase in
                    CardButton(phraseToEdit: $phraseToEdit, phrase: phrase)
                }
            }
            .padding()
            .animation(.default, value: recentPhrases.count)
        }
    }
}

#Preview {
    RecentsCardView(phraseToEdit: .constant(nil))
}
