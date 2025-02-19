//
//  VoicePickerView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 8/30/24.
//

import SwiftUI
import AVFoundation

struct VoicePickerView: View {
    @EnvironmentObject var vm: ViewModel
    
    @State private var voices: [AVSpeechSynthesisVoice] = []
//    @State private var selectedVoice: AVSpeechSynthesisVoice? = AVSpeechSynthesisVoice(language: Locale.preferredLanguages.first)

    var body: some View {
        Picker(selection: $vm.selectedVoiceIdentifier) {
            ForEach(filteredVoices.sorted { $0.name < $1.name }, id: \.identifier) { voice in
                Button(voice.name) {
                    vm.selectedVoiceIdentifier = voice.identifier
                }
//                Text(voice.name)
//                    .tag(voice as AVSpeechSynthesisVoice?)
            }
        } label: {
            Label("Selected Voice", systemImage: "waveform")
        }
        .pickerStyle(.navigationLink)
        .onAppear {
            // Load available voices
            voices = AVSpeechSynthesisVoice.speechVoices()
        }
    }
    
    private var systemLanguageCode: String {
        // Get the preferred language code of the system
        return Locale.preferredLanguages.first ?? "en"
    }

    private var filteredVoices: [AVSpeechSynthesisVoice] {
        if #available(iOS 17, *) {
            return voices.filter { $0.language.hasPrefix(systemLanguageCode) && $0.voiceTraits.contains(.isNoveltyVoice) == false }
        } else {
            return voices.filter { $0.language.hasPrefix(systemLanguageCode) }
        }
    }
}

#Preview {
    VoicePickerView()
        .environmentObject(ViewModel())
}
