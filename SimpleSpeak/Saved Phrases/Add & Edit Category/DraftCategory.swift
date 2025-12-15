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
    @Published var symbolName: String = "bookmark.fill"
    
    
    init(phraseCategory: PhraseCategory? = nil) {
        if let phraseCategory {
            id = phraseCategory.id
            title = phraseCategory.title
            symbolName = phraseCategory.symbolName
        }
    }
    
    var canBeSaved: Bool {
        title.count > 0
    }
}
