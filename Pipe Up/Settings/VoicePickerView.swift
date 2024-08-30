//
//  VoicePickerView.swift
//  Pipe Up
//
//  Created by Justin Risner on 8/30/24.
//

import SwiftUI
import AVFoundation

struct VoicePickerView: View {
    @State private var voices: [AVSpeechSynthesisVoice] = []
    @State private var selectedVoice: AVSpeechSynthesisVoice? = AVSpeechSynthesisVoice(language: Locale.preferredLanguages.first)


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

    var body: some View {
        Picker(selection: $selectedVoice) {
            ForEach(filteredVoices.sorted { $0.name < $1.name }, id: \.identifier) { voice in
                Text(voice.name)
                    .tag(voice as AVSpeechSynthesisVoice?)
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
}

#Preview {
    VoicePickerView()
}
