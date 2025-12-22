//
//  OnboardingTips.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 12/19/25.
//

import TipKit

struct MultiButtonTip: Tip {
    var title: Text {
        Text("One button, multiple uses")
    }
    
    var message: Text? {
        Text("During speech, this button controls playback; when idle, it shows the keyboard.")
    }
    
    var image: Image? {
        Image(systemName: "sparkles")
    }
}
