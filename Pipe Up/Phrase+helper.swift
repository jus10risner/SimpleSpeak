//
//  Phrase+helper.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/18/24.
//

import Foundation

extension Phrase {
    var content: String {
        get { content_ ?? "" }
        set { content_ = newValue }
    }
}
