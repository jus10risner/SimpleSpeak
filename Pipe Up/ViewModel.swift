//
//  ViewModel.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/20/24.
//

import AVFoundation
import SwiftUI

class ViewModel: ObservableObject {
    @AppStorage("useDuringCalls") var useDuringCalls = true
    @AppStorage("usePersonalVoice") var usePersonalVoice = false
    @AppStorage("appAppearance") var appAppearance: AppearanceOptions = .automatic
    
    @Published var voiceToUse = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
    
    let synthesizer = AVSpeechSynthesizer()
    
    // Speak typed text aloud
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voiceToUse
        
        synthesizer.mixToTelephonyUplink = self.useDuringCalls ? true : false
        synthesizer.speak(utterance)
    }
    
    // Set the voice to use for text-to-speech
    func assignVoice() {
        let languageCode = AVSpeechSynthesisVoice.currentLanguageCode()
        
        if #available(iOS 17, *) {
            if AVSpeechSynthesizer.personalVoiceAuthorizationStatus == .authorized && self.usePersonalVoice == true {
                print("I'm authorized to use Personal Voice!")
                // Set in case none of the voices are Personal Voice
                voiceToUse = AVSpeechSynthesisVoice(language: languageCode)
                
                for voice in AVSpeechSynthesisVoice.speechVoices() {
                    if voice.voiceTraits == .isPersonalVoice {
                        print("Personal Voice: \(voice.name)")
                        voiceToUse = AVSpeechSynthesisVoice(identifier: voice.identifier)
                    }
                }
            } else {
                print("Personal Voice not authorized")
                voiceToUse = AVSpeechSynthesisVoice(language: languageCode)
            }
        } else {
            print("This device is not compatible with Personal Voice")
            voiceToUse = AVSpeechSynthesisVoice(language: languageCode)
        }
    }
}
