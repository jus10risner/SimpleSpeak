//
//  Phrase+helper.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 6/18/24.
//

import Foundation
import SwiftUI

extension SavedPhrase {
    var text: String {
        get { text_ ?? "" }
        set { text_ = newValue }
    }
    
    var label: String {
        get { label_ ?? "" }
        set { label_ = newValue }
    }
    
    var color: PhraseColor? {
        get {
            guard let color_ else { return nil }
            return PhraseColor(rawValue: color_)
        }
        set {
            color_ = newValue?.rawValue
        }
    }
    
    func update(draftPhrase: DraftPhrase) {
        let context = DataController.shared.container.viewContext
        
        self.text = draftPhrase.text
        self.label = draftPhrase.label
        self.color = draftPhrase.color
        self.category = draftPhrase.category
        
        try? context.save()
    }
}

enum PhraseColor: String, CaseIterable, Identifiable {
    case red, orange, yellow, green, mint, cyan, blue, indigo, purple, pink, brown
    
    var value: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .mint: return .mint
        case .cyan: return .cyan
        case .blue: return .blue
        case .indigo: return .indigo
        case .purple: return .purple
        case .pink: return .pink
        case .brown: return .brown
        }
    }
    
    var id: String {
        self.rawValue
    }
}
