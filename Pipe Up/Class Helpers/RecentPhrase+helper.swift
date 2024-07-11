//
//  RecentPhrase+helper.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/24/24.
//

import Foundation

extension RecentPhrase {
    var text: String {
        get { text_ ?? "" }
        set { text_ = newValue }
    }
    
    var timeStamp: Date {
        get { timeStamp_ ?? Date() }
        set { timeStamp_ = newValue }
    }
}
