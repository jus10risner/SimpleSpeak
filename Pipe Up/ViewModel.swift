//
//  ViewModel.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/20/24.
//

import AVFoundation
import CoreData
import SwiftUI

class ViewModel: NSObject, ObservableObject {
    @Published var voiceToUse = AVSpeechSynthesisVoice(language: Locale.preferredLanguages[0])
    @Published var synthesizerState: SynthesizerState = .inactive
//    @Published var isSpeaking = false
    
    let cornerRadius: CGFloat = 15
    let listRowSpacing: CGFloat = 5
    let synthesizer = AVSpeechSynthesizer()
    
    @AppStorage("useDuringCalls") var useDuringCalls = true {
        willSet { objectWillChange.send() }
    }
    @AppStorage("usePersonalVoice") var usePersonalVoice = true {
        willSet { objectWillChange.send() }
    }
    @AppStorage("appAppearance") var appAppearance: AppearanceOptions = .automatic {
        willSet { objectWillChange.send() }
    }
    @AppStorage("selectedLanguage")  var selectedLanguage = Locale.preferredLanguages[0] {
        willSet { objectWillChange.send() }
    }
//    @AppStorage("selectedPersonalVoiceIdentifier")  var selectedPersonalVoiceIdentifier: String? {
//        willSet { objectWillChange.send() }
//    }
//    @AppStorage("selectedVoiceIdentifier") var selectedVoiceIdentifier: String = AVSpeechSynthesisVoice(language: Locale.current.identifier)?.identifier ?? "Alex" {
//        willSet { objectWillChange.send() }
//    }
    @AppStorage("selectedVoiceIdentifier") var selectedVoiceIdentifier: String? {
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
    func cancelSpeaking() {
        self.synthesizer.stopSpeaking(at: .immediate)
    }
    
    // Pause speaking
    func pauseSpeaking() {
        self.synthesizer.pauseSpeaking(at: .immediate)
    }
    
    // Continue speaking
    func continueSpeaking() {
        self.synthesizer.continueSpeaking()
    }
    
    // Removes the phrase at the given offsets
    func deletePhrase<T: NSManagedObject>(at offsets: IndexSet, from fetchedResults: FetchedResults<T>) {
        let context = DataController.shared.container.viewContext
        
        for index in offsets {
            let phrase = fetchedResults[index]
            context.delete(phrase)
            
            try? context.save()
        }
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
        if let selectedVoiceIdentifier {
            voiceToUse = AVSpeechSynthesisVoice(identifier: selectedVoiceIdentifier)
        } else {
            voiceToUse = AVSpeechSynthesisVoice(language: selectedLanguage)
        }
        
//        if AVSpeechSynthesisVoice.speechVoices().contains(where: { $0.identifier == selectedVoiceIdentifier }) && self.usePersonalVoice == true {
//            voiceToUse = AVSpeechSynthesisVoice(identifier: selectedVoiceIdentifier)
//        } else {
//            voiceToUse = AVSpeechSynthesisVoice(language: selectedLanguage)
//        }
        
//        if AVSpeechSynthesisVoice.speechVoices().contains(where: { $0.identifier == selectedVoiceIdentifier }) {
//            voiceToUse = AVSpeechSynthesisVoice(identifier: selectedVoiceIdentifier)
//        } else {
//            voiceToUse = AVSpeechSynthesisVoice(language: selectedLanguage)
//        }
        
//        if let selectedVoiceIdentifier {
//            if #available(iOS 17, *) {
//                let authorizationStatus = AVSpeechSynthesizer.personalVoiceAuthorizationStatus
//                let personalVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.voiceTraits == .isPersonalVoice }
//                
//                if personalVoices.contains(where: { $0.identifier == selectedVoiceIdentifier }) {
//                    if self.usePersonalVoice == true && authorizationStatus == .authorized {
//                        voiceToUse = AVSpeechSynthesisVoice(identifier: selectedVoiceIdentifier)
//                    } else {
//                        voiceToUse = AVSpeechSynthesisVoice(language: selectedLanguage)
//                    }
//                } else {
//                    voiceToUse = AVSpeechSynthesisVoice(identifier: selectedVoiceIdentifier)
//                }
//            } else {
//                voiceToUse = AVSpeechSynthesisVoice(identifier: selectedVoiceIdentifier)
//            }
//        } else {
//            voiceToUse = AVSpeechSynthesisVoice(language: selectedLanguage)
//        }
    }
}

enum SynthesizerState: String {
    case speaking, paused, inactive
}

// Tracks when speech begins and ends, for displaying an indicator
extension ViewModel: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("started")
        self.synthesizerState = .speaking
//        self.isSpeaking = true
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("paused")
        self.synthesizerState = .paused
//        self.isSpeaking = false
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("continued")
        self.synthesizerState = .speaking
//        self.isSpeaking = true
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("cancelled")
        self.synthesizerState = .inactive
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {}
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("finished")
        self.synthesizerState = .inactive
//        self.isSpeaking = false
    }
}
