//
//  DraftPhrase.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/19/24.
//

import Foundation

class DraftPhrase: ObservableObject {
    var id: UUID? = nil
    
    @Published var label: String = ""
    @Published var text: String = ""
    
    
    init(savedPhrase: SavedPhrase) {
        id = savedPhrase.id
        label = savedPhrase.label ?? ""
        text = savedPhrase.text
    }
    
    init() {
        self.label = label
        self.text = text
    }
    
    var canBeSaved: Bool {
        if text.count > 0 {
            return true
        } else {
            return false
        }
    }
}
