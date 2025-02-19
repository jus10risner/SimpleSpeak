//
//  Phrase+helper.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 6/18/24.
//

import Foundation

extension SavedPhrase {
    var text: String {
        get { text_ ?? "" }
        set { text_ = newValue }
    }
    
    var label: String {
        get { label_ ?? "" }
        set { label_ = newValue }
    }
    
    func update(draftPhrase: DraftPhrase) {
        let context = DataController.shared.container.viewContext
        
        self.text = draftPhrase.text
        self.label = draftPhrase.label
        self.category = draftPhrase.category
        
        try? context.save()
    }
}
