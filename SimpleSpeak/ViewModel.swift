//
//  ViewModel.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 6/20/24.
//

import AVFoundation
import CoreData
import SwiftUI

class ViewModel: NSObject, ObservableObject {
    @Published var synthesizerState: SynthesizerState = .inactive
    @Published var phraseIsRepeatable: Bool = false
    @Published var label: NSAttributedString?
    
    let cornerRadius: CGFloat = 15
    let listRowSpacing: CGFloat = 5
    lazy var synthesizer: AVSpeechSynthesizer = {
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.usesApplicationAudioSession = false // Ducked audio will only return to normal volume with this setting (when speech finishes)
        synthesizer.delegate = self
        return synthesizer
    }()
    
    @AppStorage("useDuringCalls") var useDuringCalls = true // Specifies whether audio is sent to other parties during calls
    @AppStorage("selectedVoiceIdentifier") var selectedVoiceIdentifier: String? //  Used to set the voice for speech synthesis
    @AppStorage("appAppearance") var appAppearance: AppearanceOptions = .automatic // Sets the theme for the app (auto, dark, light)
    @AppStorage("numberOfRecents") var numberOfRecents: Int = 10 // Specifies how many recent phrases to save
    @AppStorage("cellWidth") var cellWidth: PhraseCellWidthOptions = .small // Sets the width of phrase buttons (small or large)
    
    
    // MARK: - Methods
    
    // Speak typed text aloud
    func speak(_ text: String) async {
        let audioSession = AVAudioSession.sharedInstance()
        let utterance = AVSpeechUtterance(string: text)
        
        if let identifier = selectedVoiceIdentifier {
            utterance.voice = AVSpeechSynthesisVoice(identifier: identifier)
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
        }
        
        try? audioSession.setCategory(.playback, mode: .default, options: [.duckOthers])
        
        synthesizer.mixToTelephonyUplink = self.useDuringCalls ? true : false
        synthesizer.speak(utterance)
    }
    
    // Stop speaking
    func cancelSpeaking() async {
        self.synthesizer.stopSpeaking(at: .immediate)
    }
    
    // Pause speaking
    func pauseSpeaking() async {
        self.synthesizer.pauseSpeaking(at: .immediate)
    }
    
    // Continue speaking
    func continueSpeaking() async {
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
    func speakImmediately(_ text: String) {
        if self.synthesizerState != .inactive {
            Task { await self.cancelSpeaking() }
        }
        
        Task { await self.speak(text) }
    }
    
    func checkSpeechVoice() async {
        if !AVSpeechSynthesisVoice.speechVoices().contains(where: { $0.identifier == self.selectedVoiceIdentifier }) {
            let languageCode = AVSpeechSynthesisVoice.currentLanguageCode()
            
            if let defaultVoice = AVSpeechSynthesisVoice(language: languageCode) {
                let defaultVoiceIdentifier = defaultVoice.identifier
                
                Task { @MainActor in
                    self.selectedVoiceIdentifier = defaultVoiceIdentifier
                }
            }
        }
    }
    
    @available(iOS 17, *)
    func requestPersonalVoiceAccess() {
        AVSpeechSynthesizer.requestPersonalVoiceAuthorization { result in
            if result == .authorized {
                let personalVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.voiceTraits == .isPersonalVoice }
                
                self.selectedVoiceIdentifier = personalVoices.first?.identifier
            } else {
                Task {
                    await self.checkSpeechVoice()
                }
            }
        }
    }
}

enum PhraseCellWidthOptions: Int, CaseIterable {
    case small = 150, large = 250
}

enum SynthesizerState: String {
    case speaking, paused, inactive
}

// Tracks when speech begins and ends, for displaying an indicator
extension ViewModel: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("started")
        self.phraseIsRepeatable = false
        Task { @MainActor in
            self.synthesizerState = .speaking
        }
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("paused")
        Task { @MainActor in
            self.synthesizerState = .paused
        }
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("continued")
        Task { @MainActor in
            self.synthesizerState = .speaking
        }
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("cancelled")
        Task { @MainActor in
            self.synthesizerState = .inactive
        }
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString, attributes: [.font: UIFont.preferredFont(forTextStyle: .title3), .foregroundColor: UIColor.secondaryLabel])
        mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.label, range: characterRange)
        
        withAnimation {
            label = mutableAttributedString
        }
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        withAnimation {
            label = nil
        }
        
        print("finished")
        self.phraseIsRepeatable = true
        Task { @MainActor in
            self.synthesizerState = .inactive
        }
    }
}
