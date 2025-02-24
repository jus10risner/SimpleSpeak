//
//  DraftCategory.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 9/19/24.
//

import Foundation

class DraftCategory: ObservableObject {
    var id: UUID? = nil
    
    @Published var title: String = ""
    @Published var symbolName: String = "hand.wave.fill"
    
    
    init(phraseCategory: PhraseCategory) {
        id = phraseCategory.id
        title = phraseCategory.title
        symbolName = phraseCategory.symbolName
    }
    
    init() {
        self.title = title
        self.symbolName = symbolName
    }
    
    var canBeSaved: Bool {
        if title.count > 0 {
            return true
        } else {
            return false
        }
    }
}
