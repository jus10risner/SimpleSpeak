//
//  OnboardingTips.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 12/19/25.
//

import TipKit

struct MultiButtonTip: Tip {
    var title: Text {
        Text("Always the right control")
    }
    
    var message: Text? {
        Text("This button shows speech controls during speech and the keyboard when speech is idle.")
    }
    
    var image: Image? {
        Image(systemName: "sparkles")
    }
    
    var options: [any Option] {
        // Tip will only appear once before it is automatically invalidated.
        MaxDisplayCount(1)
    }
    
    // MARK: - Rule for displaying this tip
    
    static let didTapPhraseButton = Event(id: "didTapPhraseButton")
    
    var rules: [Rule] {
        [
            #Rule(Self.didTapPhraseButton) {
                $0.donations.count == 1
            }
        ]
    }
}
