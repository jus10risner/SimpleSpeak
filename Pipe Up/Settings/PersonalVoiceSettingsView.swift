//
//  PersonalVoiceSettingsView.swift
//  Pipe Up
//
//  Created by Justin Risner on 9/23/24.
//

import AVFoundation
import SwiftUI

struct PersonalVoiceSettingsView: View {
    @EnvironmentObject var vm: ViewModel
    @State private var showingPersonalVoiceAlert = false
    @State private var showingRestartAlert = false
    @State private var showingPersonalVoiceSetupSheet = false
    
    var body: some View {
        if #available(iOS 17, *) {
            Section {
                if AVSpeechSynthesizer.personalVoiceAuthorizationStatus == .denied {
                    Text("Unavailable")
                        .foregroundStyle(Color.secondary)
                } else {
                    Toggle(isOn: $vm.usePersonalVoice, label: {
                        Label("Use Personal Voice", systemImage: "waveform.and.person.filled")
                    })
                }
                
                // TODO: Handle the case where multiple Personal Voices exist
//                if vm.usePersonalVoice == true && vm.personalVoices.count > 1 {
//                    Picker(selection: $vm.selectedVoiceIdentifier) {
//                        ForEach(vm.personalVoices, id: \.self) { voice in
//                            Button {
//                                vm.selectedVoiceIdentifier = voice.identifier
//                            } label: {
//                                Text(voice.name)
//                            }
//                        }
//                    } label: {
//                        Label("Selected Voice", systemImage: "waveform")
//                    }
//                }
            } header: {
                Text("Personal Voice")
            } footer: {
                Text("To set up and manage your Personal Voice, go to Settings > Accessiblity > Personal Voice.")
            }
//            .task {
//                await fetchPersonalVoices()
//            }
            .onAppear {
                if AVSpeechSynthesizer.personalVoiceAuthorizationStatus != .authorized {
                    vm.usePersonalVoice = false
                }
            }
            .onChange(of: vm.selectedVoiceIdentifier) { _ in
                vm.assignVoice()
            }
            .onChange(of: vm.usePersonalVoice) { toggle in
                if toggle == true {
                    checkPersonalVoiceStatus()
                }
                
                vm.assignVoice()
            }
            .sheet(isPresented: $showingPersonalVoiceSetupSheet, content: {
                NavigationStack {
                        SafariView(url: URL(string: "https://support.apple.com/en-us/104993")!)
                            .edgesIgnoringSafeArea(.bottom)
//                    WebView(url: URL(string: "https://support.apple.com/en-us/104993")!)
//                        .navigationTitle("Personal Voice")
//                        .navigationBarTitleDisplayMode(.inline)
//                        .toolbar {
//                            ToolbarItem(placement: .topBarTrailing) {
//                                Button("Done") {
//                                    showingPersonalVoiceSetupSheet = false
//                                }
//                            }
//                        }
                }
            })
//            .sheet(isPresented: $showingAppRestartInstructions) {
//                SafariView(url: URL(string: "https://support.apple.com/guide/iphone/quit-and-reopen-an-app-iph83bfec492/ios")!)
//                    .edgesIgnoringSafeArea(.bottom)
//            }
            .alert("Personal Voice Unavailable", isPresented: $showingPersonalVoiceAlert) {
                Button("OK") { vm.usePersonalVoice = false }
                Button("Learn More") { showingPersonalVoiceSetupSheet = true }
            } message: {
                Text("It looks like Personal Voice is either unavailable on this device, or access was previously denied.")
            }
            .alert(isPresented: $showingRestartAlert) {
                Alert(title: Text("Restart Required"),
                      message: Text("To use Personal Voice, please quit and reopen the app."),
                      // This closes/crashes the app, so Personal Voices can be fetched on the next launch. I don't like this solution, but the alternative is to have the user force-quit and reopen the app, which is a worse experience for them.
                      primaryButton: .destructive(Text("Close App"), action: { fatalError() }),
                      secondaryButton: .cancel(Text("OK"))
                )
            }
        }
    }
    
    @available(iOS 17, *)
    func checkPersonalVoiceStatus() {
//        let personalVoiceStatus = AVSpeechSynthesizer.personalVoiceAuthorizationStatus
        
//        if vm.usePersonalVoice == false {
//            vm.fetchPersonalVoices()
//        } else {
            switch AVSpeechSynthesizer.personalVoiceAuthorizationStatus {
            case .notDetermined:
                requestPersonalVoiceAuthorization()
            case .authorized:
                vm.fetchPersonalVoices()
//            case .denied:
//                showingPersonalVoiceAlert = true
            default:
                showingPersonalVoiceAlert = true
            }
//        }
    }
    
    @available(iOS 17, *)
    func requestPersonalVoiceAuthorization() {
        AVSpeechSynthesizer.requestPersonalVoiceAuthorization { status in
            if status == .authorized {
                print("I'm authorized to use Personal Voice!")
                showingRestartAlert = true
            } else {
                print("Personal Voice not authorized")
                vm.usePersonalVoice = false
            }
        }
    }
}

#Preview {
    PersonalVoiceSettingsView()
        .environmentObject(ViewModel())
}
