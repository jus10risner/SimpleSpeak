//
//  SettingsView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/19/24.
//

import AVFoundation
import SwiftUI

struct SettingsView: View {
    let languageCode = AVSpeechSynthesisVoice.currentLanguageCode()
    @State private var voiceToUse = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
    @State private var usePersonalVoice = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if #available(iOS 17, *) {
                        Toggle(isOn: $usePersonalVoice, label: {
                            Label("Personal Voice", systemImage: "waveform")
                        })
                        .onChange(of: usePersonalVoice) { _ in
                            assignVoice()
                        }
                    }
                }
            }
        }
    }
    
    // Set the voice to use for text-to-speech
    func assignVoice() {
        if #available(iOS 17, *) {
            AVSpeechSynthesizer.requestPersonalVoiceAuthorization { status in
                // check `status` to see if you're authorized and then refetch your voices
                if status == .authorized {
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
                
                print(status)
            }
        } else {
            print("This device is not compatible with Personal Voice")
            voiceToUse = AVSpeechSynthesisVoice(language: languageCode)
        }
    }
}

#Preview {
    SettingsView()
}
