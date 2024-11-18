//
//  VoiceSelectionView.swift
//  Pipe Up
//
//  Created by Justin Risner on 11/15/24.
//

import AVFoundation
import SwiftUI

struct VoiceSelectionView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var vm: ViewModel
    
    @State private var standardVoices: [AVSpeechSynthesisVoice] = []
    @State private var noveltyVoices: [AVSpeechSynthesisVoice] = []
    @State private var personalVoices: [AVSpeechSynthesisVoice] = []
    
    var body: some View {
        List {
            if !personalVoices.isEmpty {
                Section {
                    Picker("Personal Voices", selection: $vm.selectedVoiceIdentifier) {
                        ForEach(personalVoices, id: \.identifier) { voice in
                            Button(voice.name) {
                                vm.selectedVoiceIdentifier = voice.identifier
                            }
                            .tag(voice.identifier as String?)
                            .buttonStyle(.plain)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                } header: {
                    Text("Personal Voices")
                } footer: {
                    Text("To manage, go to Settings > Accessiblity > Personal Voice.")
                }
            }
            
            Section {
                Picker("Standard", selection: $vm.selectedVoiceIdentifier) {
                    ForEach(standardVoices, id: \.identifier) { voice in
                        Button(voice.name) {
                            vm.selectedVoiceIdentifier = voice.identifier
                        }
                        .tag(voice.identifier as String?)
                        .buttonStyle(.plain)
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
            } header: {
                Text("Standard")
            } footer: {
                Text("To manage voices, go to Settings > Accessiblity > Spoken Content > Voices")
            }
            
            if !noveltyVoices.isEmpty {
                Picker("Novelty", selection: $vm.selectedVoiceIdentifier) {
                    ForEach(noveltyVoices, id: \.identifier) { voice in
                        Button(voice.name) {
                            vm.selectedVoiceIdentifier = voice.identifier
                        }
                        .tag(voice.identifier as String?)
                        .buttonStyle(.plain)
                    }
                }
                .pickerStyle(.inline)
            }
        }
        .navigationTitle("Voices")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadVoices() }
        .onChange(of: scenePhase) { newValue in
            // Updates the list of voices, when a user downloads or deletes a speech synthesis voice in the Settings app
            if newValue == .active {
                Task { await loadVoices() }
            }
        }
    }
    
    private func loadVoices() async {
        let noveltyNames = ["Albert", "Bad News", "Bahh", "Bells", "Boing", "Bubbles", "Cellos", "Good News", "Jester", "Organ", "Superstar", "Trinoids", "Whisper", "Wobble", "Zarvox"]
        
        let allVoices = AVSpeechSynthesisVoice.speechVoices().sorted { $0.name < $1.name }
        let voicesForCurrentLanguage = allVoices.filter { $0.language.starts(with: Locale.preferredLanguages[0]) }
        
        if #available(iOS 17, *) {
            standardVoices = voicesForCurrentLanguage.filter { $0.voiceTraits != .isNoveltyVoice && $0.voiceTraits != .isPersonalVoice }
            noveltyVoices = voicesForCurrentLanguage.filter { $0.voiceTraits == .isNoveltyVoice }
            personalVoices = voicesForCurrentLanguage.filter { $0.voiceTraits == .isPersonalVoice }
        } else {
            standardVoices = voicesForCurrentLanguage.filter { !noveltyNames.contains($0.name) }
            noveltyVoices = voicesForCurrentLanguage.filter { noveltyNames.contains($0.name) }
        }
    }
}

#Preview {
    VoiceSelectionView()
}
