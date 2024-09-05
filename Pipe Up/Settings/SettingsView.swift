//
//  SettingsView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/19/24.
//

import AVFoundation
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: ViewModel
    @State private var showingPersonalVoiceAlert = false
    @State private var personalVoices: [AVSpeechSynthesisVoice] = []
//    @State private var showingPersonalVoiceSetupSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $vm.useDuringCalls, label: {
                        Label("Use During Calls", systemImage: "phone.fill")
                    })
                } footer: {
                    Text("Determines whether your typed phrases are spoken aloud to the other party on a phone call.")
                }
                
                if #available(iOS 17, *) {
//                    // TODO: Re-enable check that only shows Personal Voice info if the device supports it
                    if AVSpeechSynthesizer.personalVoiceAuthorizationStatus != .unsupported {
                        
                        //                    let personalVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.voiceTraits == .isPersonalVoice }
                        
                        if AVSpeechSynthesizer.personalVoiceAuthorizationStatus == .authorized && AVSpeechSynthesisVoice.speechVoices().contains(where: { $0.voiceTraits == .isPersonalVoice })
                        {
                            Section {
                                Toggle(isOn: $vm.usePersonalVoice, label: {
                                    Label("Use Personal Voice", systemImage: "waveform.and.person.filled")
                                })
                                
                                // TODO: Handle the case where multiple Personal Voices exist
                                if vm.usePersonalVoice == true && personalVoices.count > 1 {
                                    Picker(selection: $vm.selectedVoiceIdentifier) {
                                        ForEach(personalVoices, id: \.self) { voice in
                                            Button {
                                                vm.selectedVoiceIdentifier = voice.identifier
                                            } label: {
                                                Text(voice.name)
                                            }
                                        }
                                    } label: {
                                        Label("Selected Voice", systemImage: "waveform")
                                    }
                                }
                            } footer: {
                                Text("Have the app speak with your voice, using Apple's Personal Voice feature.")
                            }
                        }
                    }
                    
//                    // TODO: Re-enable check that only shows this section if Personal Voices exist
//                    if AVSpeechSynthesisVoice.speechVoices().contains(where: { $0.voiceTraits == .isPersonalVoice }) {
//                    let personalVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.voiceTraits == .isPersonalVoice }
//                        
//                        Section {
//                            Toggle(isOn: $vm.usePersonalVoice, label: {
//                                Label("Use Personal Voice", systemImage: "waveform.and.person.filled")
//                            })
//
//                            // TODO: Handle the case where multiple Personal Voices exist
//                            if vm.usePersonalVoice == true && personalVoices.count > 1 {
//                                Picker(selection: $vm.selectedVoiceIdentifier) {
//                                    ForEach(personalVoices, id: \.self) { voice in
//                                        Button {
//                                            vm.selectedVoiceIdentifier = voice.identifier
//                                        } label: {
//                                            Text(voice.name)
//                                        }
//                                    }
//                                } label: {
//                                    Label("Selected Voice", systemImage: "waveform")
//                                }
//                            }
//                        } footer: {
//                            Text("Have the app speak with your voice, using Apple's Personal Voice feature.")
//                        }
//                    }
                }
////                    else {
////                            Button("About Personal Voice") {
////                                // TODO: Create view that explains how to set up Personal Voice
////                                showingPersonalVoiceSetupSheet = true
////                            }
////                        }
////                    }
//                }
                
                // TODO: Re-enable conditional
//                if Locale.preferredLanguages.count > 1 {
//                    Section {
//                        Picker(selection: $vm.selectedLanguage) {
//                            languagePicker
//                        } label: {
//                            Label("Speech Language", systemImage: "quote.bubble.fill")
//                        }
//                    }
//                }
                
//                Section {
////                    VoicePickerView()
//                    
//                    // TODO: Use conditional logic, to show this only on supported devices that have the feature enabled
//                    Toggle(isOn: $vm.usePersonalVoice, label: {
//                        Label("Use Personal Voice", systemImage: "waveform.and.person.filled")
//                    })
//                }
                
                Section {
                    Picker(selection: $vm.appAppearance) {
                        ForEach(AppearanceOptions.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    } label: {
                        Label("App Theme", systemImage: "circle.lefthalf.filled")
                    }
                    .onChange(of: vm.appAppearance) { _ in
                        AppearanceController.shared.setAppearance()
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .task {
            if #available(iOS 17.0, *) {
                await fetchPersonalVoices()
            }
        }
//        .onAppear {
//            if #available(iOS 17.0, *) {
//                if AVSpeechSynthesizer.personalVoiceAuthorizationStatus != .authorized {
//                    vm.usePersonalVoice = false
//                }
//            }
//        }
        .onChange(of: vm.usePersonalVoice) { toggle in
            if #available(iOS 17, *) {
                if toggle == false {
                    vm.selectedVoiceIdentifier = nil
                } else {
                    vm.selectedVoiceIdentifier = personalVoices[0].identifier
                }
            }
            
            vm.assignVoice()
        }
//        .onChange(of: vm.selectedLanguage) { _ in vm.assignVoice() }
        .onChange(of: vm.selectedVoiceIdentifier) { _ in
            vm.assignVoice()
        }
//        .onChange(of: vm.usePersonalVoice) { toggle in
//            if #available(iOS 17, *) {
//                if toggle == false {
//                    vm.selectedPersonalVoiceIdentifier = nil
//                } else {
//                    switch AVSpeechSynthesizer.personalVoiceAuthorizationStatus {
//                    case .notDetermined:
//                        vm.requestPersonalVoiceAuthorization()
//                    case .denied:
//                        showingPersonalVoiceAlert = true
//                    default:
//                        return
//                    }
//                }
//                
//                vm.assignVoice()
//            }
//        }
//        .sheet(isPresented: $showingPersonalVoiceSetupSheet, content: {
//            NavigationStack {
////                    SafariView(url: URL(string: "https://support.apple.com/en-us/104993")!)
////                        .edgesIgnoringSafeArea(.bottom)
//                WebView(url: URL(string: "https://support.apple.com/en-us/104993")!)
//                    .navigationTitle("Personal Voice")
//                    .navigationBarTitleDisplayMode(.inline)
//                    .toolbar {
//                        ToolbarItem(placement: .topBarTrailing) {
//                            Button("Done") {
//                                showingPersonalVoiceSetupSheet = false
//                            }
//                        }
//                    }
//            }
//        })
        .alert("Personal Voice Not Authorized", isPresented: $showingPersonalVoiceAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("It looks like you previously denied access to your Personal Voice. To manually grant access, please go to Settings -> Accessibility -> Personal Voice")
        }
    }
    
    @available(iOS 17, *)
//    func fetchPersonalVoices() {
    func fetchPersonalVoices() async {
//        AVSpeechSynthesizer.requestPersonalVoiceAuthorization() { status in
            if AVSpeechSynthesizer.personalVoiceAuthorizationStatus == .authorized {
                personalVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.voiceTraits.contains(.isPersonalVoice) }
            }
//        }
    }
    
    // Allows user to select from their preferred languages, as defined in Settings -> General -> Language & Region
//    var languagePicker: some View {
//        let location = Locale.current
//        
//        return ForEach(Locale.preferredLanguages, id: \.self) { language in
//            Button {
//                vm.selectedLanguage = language
//            } label: {
//                Text(location.localizedString(forLanguageCode: language) ?? language.description)
//            }
//        }
//    }
}

#Preview {
    SettingsView()
        .environmentObject(ViewModel())
}
