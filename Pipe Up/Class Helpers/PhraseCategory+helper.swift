//
//  PhraseCategory+helper.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/28/24.
//

import Foundation

extension PhraseCategory {
    var title: String {
        get { title_ ?? "" }
        set { title_ = newValue }
    }
    
    func updateCategory(title: String) {
        let context = DataController.shared.container.viewContext
        
        self.title = title
        
        try? context.save()
    }
    
    // Used for exporting app data
    var phrasesArray: [SavedPhrase] {
        let set = phrases as? Set<SavedPhrase> ?? []
        
        return set.sorted {
            $0.label < $1.label
        }
    }
}
