//
//  OnboardingTips.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 12/19/25.
//

import TipKit

struct MultiButtonTip: Tip {
    var title: Text {
        Text("Controls That Adapt")
    }
    
    var message: Text? {
        Text("This button shows playback controls during speech and opens the keyboard when speech is not playing.")
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
