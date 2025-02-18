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
    
    @State private var showingPersonalVoiceInfo = false
    
    var body: some View {
        List {
            if #available(iOS 17, *) {
                Section {
                    if !personalVoices.isEmpty { // Only show this section if Personal Voices exist
                        Picker("Personal Voice", selection: $vm.selectedVoiceIdentifier) {
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
                    } else {
                        Text("No available voices")
                            .foregroundStyle(Color.secondary)
                    }
                } header: {
                    Text("Personal Voice")
                } footer: {
                    if AVSpeechSynthesizer.personalVoiceAuthorizationStatus == .authorized {
                        Text("Manage your Personal Voice in the Settings app, under Accessibility > Personal Voice.")
                    } else {
                        Button("Learn about Personal Voice") { showingPersonalVoiceInfo = true }
                            .font(.footnote)
                    }
                }
            }
            
            Section {
                Picker("Standard Voices", selection: $vm.selectedVoiceIdentifier) {
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
                Text("Standard Voices")
            } footer: {
                Text("Manage system voices in the Settings app, under Accessibility > Spoken Content > Voices.")
            }
            
            if !noveltyVoices.isEmpty {
                Picker("Novelty Voices", selection: $vm.selectedVoiceIdentifier) {
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
        .sheet(isPresented: $showingPersonalVoiceInfo, content: {
            SafariView(url: URL(string: "https://support.apple.com/en-us/104993")!)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
        .task { await loadVoices() }
        .onChange(of: scenePhase) { newValue in
            // Updates the list of voices, in case a user adds/deletes/modifies a speech synthesis voice in the Settings app
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

//#Preview {
//    VoiceSelectionView()
//        .environmentObject(ViewModel())
//}
