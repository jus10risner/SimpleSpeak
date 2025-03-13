//
//  PhraseCategory+helper.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 6/28/24.
//

import Foundation

extension PhraseCategory {
    var title: String {
        get { title_ ?? "" }
        set { title_ = newValue }
    }
    
    var symbolName: String {
        get { symbolName_ ?? "" }
        set { symbolName_ = newValue }
    }
    
    func update(draftCategory: DraftCategory) {
        let context = DataController.shared.container.viewContext
        
        self.title = draftCategory.title
        self.symbolName = draftCategory.symbolName
        
        try? context.save()
    }
}
