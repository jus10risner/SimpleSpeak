//
//  Phrase+helper.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/18/24.
//

import Foundation

extension SavedPhrase {
    var text: String {
        get { text_ ?? "" }
        set { text_ = newValue }
    }
}
