//
//  SettingsView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/19/24.
//

import AVFoundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vm: ViewModel
    @State private var selectedPersonalVoiceIdentifier: String?
    @State private var selectedPersonalVoice: AVSpeechSynthesisVoice?
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $vm.useDuringCalls, label: {
                        Label("Use During Calls", systemImage: "phone.fill")
                    })
                } footer: {
                    Text("This speaks your typed phrases aloud to the other party on a phone call.")
                }
                
                if #available(iOS 17, *) {
                    Section {
                        Toggle(isOn: $vm.usePersonalVoice, label: {
                            Label("Use Personal Voice", systemImage: "waveform")
                        })
                        
                        // TODO: Handle the case where multiple Personal Voices exist
//                        if personalVoices.count > 1 {
//                            let personalVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.voiceTraits == .isPersonalVoice }
//                            
//                            Picker("Select a Personal Voice", selection: $selectedPersonalVoice) {
//                                ForEach(personalVoices, id: \.self) {
//                                    Text($0.name)
//                                }
//                            }
//                        }
                        .onChange(of: vm.usePersonalVoice) { _ in
                            requestPersonalVoiceAuthorization()
                        }
                    } footer: {
                        Text("Have the app speak with your voice, using Apple's Personal Voice feature.")
                    }
                }
                
                Section {
                    Picker(selection: $vm.appAppearance, content: {
                        ForEach(AppearanceOptions.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }, label: {
                        Label("App Theme", systemImage: "circle.lefthalf.filled")
                    })
                    .pickerStyle(.navigationLink)
                    .onChange(of: vm.appAppearance) { _ in
                        AppearanceController.shared.setAppearance()
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            if #available(iOS 17.0, *) {
                if AVSpeechSynthesizer.personalVoiceAuthorizationStatus != .authorized {
                    vm.usePersonalVoice = false
                }
            }
        }
    }
    
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
}

#Preview {
    SettingsView()
        .environmentObject(ViewModel())
}
