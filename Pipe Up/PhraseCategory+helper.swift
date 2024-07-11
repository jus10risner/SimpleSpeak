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
    
    var sortedPhrases: [SavedPhrase] {
        let set = phrases as? Set<SavedPhrase> ?? []
        
        return set.sorted {
            $0.text > $1.text
        }
    }
}
