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
    @Published var synthesizerState: SynthesizerState = .inactive
    @Published var phraseIsRepeatable: Bool = false
    
    let cornerRadius: CGFloat = 15
    let listRowSpacing: CGFloat = 5
//    let synthesizer = AVSpeechSynthesizer()
    lazy var synthesizer: AVSpeechSynthesizer = {
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        return synthesizer
    }()
    
    @AppStorage("useDuringCalls") var useDuringCalls = true {
        willSet { objectWillChange.send() }
    }
    @AppStorage("selectedVoiceIdentifier") var selectedVoiceIdentifier: String? {
        willSet { objectWillChange.send() }
    }
    @AppStorage("appAppearance") var appAppearance: AppearanceOptions = .automatic {
        willSet { objectWillChange.send() }
    }
    @AppStorage("numberOfRecents") var numberOfRecents: Int = 10 {
        willSet { objectWillChange.send() }
    }
    
//    override init() {
//        super.init()
//        self.synthesizer.delegate = self
//    }
    
    
    // MARK: - Methods
    
    // Speak typed text aloud
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        
        if let identifier = selectedVoiceIdentifier {
            utterance.voice = AVSpeechSynthesisVoice(identifier: identifier)
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playback, mode: .default, options: [.duckOthers])
        
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
    func deletePhrase<T: NSManagedObject>(at offsets: IndexSet, from fetchedResults: FetchedResults<T>, in context: NSManagedObjectContext) {
        for index in offsets {
            let phrase = fetchedResults[index]
            context.delete(phrase)
            
            try? context.save()
        }
    }
    
    // Cancels any speech that may be occurring, before speaking the given phrase
    func cancelAndSpeak(_ phrase: SavedPhrase) {
        if self.synthesizerState != .inactive {
            self.cancelSpeaking()
        }
        
        self.speak(phrase.text)
    }
    
    func checkSpeechVoice() async {
        if !AVSpeechSynthesisVoice.speechVoices().contains(where: { $0.identifier == self.selectedVoiceIdentifier }) {
            let languageCode = AVSpeechSynthesisVoice.currentLanguageCode()
            let defaultVoiceIdentifier = AVSpeechSynthesisVoice(language: languageCode)?.identifier
            
            self.selectedVoiceIdentifier = defaultVoiceIdentifier
        }
    }
    
    @available(iOS 17, *)
    func requestPersonalVoiceAccess() {
        AVSpeechSynthesizer.requestPersonalVoiceAuthorization { result in
            if result == .authorized {
                let personalVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.voiceTraits == .isPersonalVoice }
                
                self.selectedVoiceIdentifier = personalVoices.first?.identifier
            }
        }
    }
}

enum SynthesizerState: String {
    case speaking, paused, inactive
}

// Tracks when speech begins and ends, for displaying an indicator
extension ViewModel: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("started")
        self.phraseIsRepeatable = false
        self.synthesizerState = .speaking
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("paused")
        self.synthesizerState = .paused
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("continued")
        self.synthesizerState = .speaking
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("cancelled")
        self.synthesizerState = .inactive
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("finished")
        self.phraseIsRepeatable = true
        self.synthesizerState = .inactive
    }
}
