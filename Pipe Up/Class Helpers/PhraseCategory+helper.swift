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
}
