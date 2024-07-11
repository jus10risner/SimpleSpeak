//
//  ViewModel.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/20/24.
//

import AVFoundation
import SwiftUI

class ViewModel: NSObject, ObservableObject {
    @Published var voiceToUse = AVSpeechSynthesisVoice(language: Locale.preferredLanguages[0])
    @Published var isSpeaking = false
    
    let cornerRadius: CGFloat = 15
    let listRowSpacing: CGFloat = 5
    let synthesizer = AVSpeechSynthesizer()
    
    @AppStorage("useDuringCalls") var useDuringCalls = true {
        willSet { objectWillChange.send() }
    }
    @AppStorage("usePersonalVoice") var usePersonalVoice = false {
        willSet { objectWillChange.send() }
    }
    @AppStorage("appAppearance") var appAppearance: AppearanceOptions = .automatic {
        willSet { objectWillChange.send() }
    }
    @AppStorage("selectedLanguage")  var selectedLanguage = Locale.preferredLanguages[0] {
        willSet { objectWillChange.send() }
    }
    @AppStorage("selectedVoiceIdentifier")  var selectedPersonalVoiceIdentifier: String? {
        willSet { objectWillChange.send() }
    }
    
    override init() {
        super.init()
        self.synthesizer.delegate = self
    }
    
    
    // MARK: - Methods
    
    // Speak typed text aloud
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voiceToUse
        
        synthesizer.mixToTelephonyUplink = self.useDuringCalls ? true : false
        synthesizer.speak(utterance)
    }
    
    // Stop speaking
    func stopSpeaking() {
        self.synthesizer.stopSpeaking(at: .immediate)
    }
    
    // Request to use Personal Voice, if iOS 17 is available
    @available(iOS 17, *)
    func requestPersonalVoiceAuthorization() {
        AVSpeechSynthesizer.requestPersonalVoiceAuthorization { status in
            if status == .authorized {
                print("I'm authorized to use Personal Voice!")
            } else {
                print("Personal Voice not authorized")
            }
        }
    }
    
    // Set the voice to use for text-to-speech
    func assignVoice() {
        if #available(iOS 17, *) {
            let authorizationStatus = AVSpeechSynthesizer.personalVoiceAuthorizationStatus
            let personalVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.voiceTraits == .isPersonalVoice }
            
            if self.usePersonalVoice == true && authorizationStatus == .authorized {
                if personalVoices.count > 0 && self.selectedPersonalVoiceIdentifier == nil {
                    self.selectedPersonalVoiceIdentifier = personalVoices.first?.identifier
                }
            } else {
                self.selectedPersonalVoiceIdentifier = nil
            }
            
            if let identifier = self.selectedPersonalVoiceIdentifier {
                voiceToUse = AVSpeechSynthesisVoice(identifier: identifier)
            } else {
                voiceToUse = AVSpeechSynthesisVoice(language: selectedLanguage)
            }
        } else {
            voiceToUse = AVSpeechSynthesisVoice(language: selectedLanguage)
        }
        
        
//        if #available(iOS 17, *) {
//            if AVSpeechSynthesizer.personalVoiceAuthorizationStatus == .authorized && self.usePersonalVoice == true {
//                print("I'm authorized to use Personal Voice!")
//                // Set in case none of the voices are Personal Voice
//                voiceToUse = AVSpeechSynthesisVoice(language: languageCode)
//                
//                for voice in AVSpeechSynthesisVoice.speechVoices() {
//                    if voice.voiceTraits == .isPersonalVoice {
//                        print("Personal Voice: \(voice.name)")
//                        voiceToUse = AVSpeechSynthesisVoice(identifier: voice.identifier)
//                    }
//                }
//            } else {
//                print("Personal Voice not authorized")
//                voiceToUse = AVSpeechSynthesisVoice(identifier: self.selectedVoiceIdentifier)
//                
//            }
//        } else {
//            print("This device is not compatible with Personal Voice")
//            voiceToUse = AVSpeechSynthesisVoice(identifier: self.selectedVoiceIdentifier)
//        }
    }
}

// Tracks when speech begins and ends, for displaying an indicator
extension ViewModel: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("started")
        self.isSpeaking = true
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {}
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {}
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {}
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {}
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("finished")
        self.isSpeaking = false
    }
}
