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
//    @Published var voiceToUse: AVSpeechSynthesisVoice?
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
//    @AppStorage("usePersonalVoice") var usePersonalVoice = false {
//        willSet { objectWillChange.send() }
//    }
    @AppStorage("selectedVoiceIdentifier") var selectedVoiceIdentifier: String? {
        willSet { objectWillChange.send() }
    }
//    @AppStorage("selectedLanguage")  var selectedLanguage = Locale.preferredLanguages[0] {
//        willSet { objectWillChange.send() }
//    }
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
        
//        synthesizer.speak(utterance)
//        utterance.voice = voiceToUse
        
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
    
    // Populates the personalVoices array, and selects the first available Personal Voice, if no selectedVoiceIdentifer has been prveiously set
//    @available(iOS 17, *)
//    func fetchPersonalVoices() async {
////        
////        if selectedVoiceIdentifier == nil {
////            if let firstVoice = personalVoices.first {
////                selectedVoiceIdentifier = firstVoice.identifier
////            }
////        }
//        
//        AVSpeechSynthesizer.requestPersonalVoiceAuthorization() { status in
//            if status == .authorized {
//                self.personalVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.voiceTraits.contains(.isPersonalVoice) }
//                
//                if self.selectedVoiceIdentifier == nil {
//                    if let firstVoice = self.personalVoices.first {
//                        self.selectedVoiceIdentifier = firstVoice.identifier
//                    }
//                }
//            }
//        }
//        
//        assignVoice()
//    }
    
    func checkSpeechVoice() async {
        if !AVSpeechSynthesisVoice.speechVoices().contains(where: { $0.identifier == self.selectedVoiceIdentifier }) {
            let languageCode = AVSpeechSynthesisVoice.currentLanguageCode()
            let defaultVoiceIdentifier = AVSpeechSynthesisVoice(language: languageCode)?.identifier
            
            self.selectedVoiceIdentifier = defaultVoiceIdentifier
        }
    }
    
    // Set the voice to use for text-to-speech
//    func assignVoice() {
//        if let identifier = selectedVoiceIdentifier {
////            if self.usePersonalVoice == true {
//            voiceToUse = AVSpeechSynthesisVoice(identifier: identifier)
////            } else {
////                voiceToUse = AVSpeechSynthesisVoice(language: selectedLanguage)
////            }
//        } else {
//            voiceToUse = AVSpeechSynthesisVoice(language: selectedLanguage)
//        }
//    }
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
//        try? AVAudioSession.sharedInstance().setActive(true)
//        try? AVAudioSession.sharedInstance().setCategory(.playback, options: .interruptSpokenAudioAndMixWithOthers)
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        
        print("finished")
        self.phraseIsRepeatable = true
        self.synthesizerState = .inactive
    }
}
