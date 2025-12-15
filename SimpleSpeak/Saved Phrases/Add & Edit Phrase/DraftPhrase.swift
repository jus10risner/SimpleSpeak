//
//  DraftPhrase.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 7/19/24.
//

import Foundation

class DraftPhrase: ObservableObject {
    var id: UUID? = nil
    
    @Published var label: String = ""
    @Published var text: String = ""
    @Published var color: PhraseColor? = nil
    @Published var category: PhraseCategory?
    
    
    init(savedPhrase: SavedPhrase? = nil) {
        if let savedPhrase {
            id = savedPhrase.id
            label = savedPhrase.label
            text = savedPhrase.text
            color = savedPhrase.color
            category = savedPhrase.category
        }
    }
    
    var canBeSaved: Bool {
        text.count > 0
    }
}
