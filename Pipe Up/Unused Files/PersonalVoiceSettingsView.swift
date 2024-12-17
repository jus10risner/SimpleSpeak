////
////  PersonalVoiceSettingsView.swift
////  Pipe Up
////
////  Created by Justin Risner on 9/23/24.
////
//
//import AVFoundation
//import SwiftUI
//
//@available(iOS 17, *)
//struct PersonalVoiceSettingsView: View {
//    @EnvironmentObject var vm: ViewModel
//    @Binding var showingpersonalVoiceSetupSheet: Bool
//    
////    @State private var showingPersonalVoiceAlert = false
////    @State private var showingRestartAlert = false
//    @State private var personalVoices: [AVSpeechSynthesisVoice] = []
//    
//    var body: some View {
//        Section {
//            if AVSpeechSynthesizer.personalVoiceAuthorizationStatus == .authorized {
//                Toggle(isOn: $vm.usePersonalVoice, label: {
//                    Label("Use Personal Voice", systemImage: "waveform.and.person.filled")
//                })
//            } else {
//                Button("About Personal Voice") {
//                    showingpersonalVoiceSetupSheet = true
//                }
//            }
//            
//            // TODO: Handle the case where multiple Personal Voices exist
//            if vm.usePersonalVoice == true && personalVoices.count > 1 {
//                Picker("Selected Voice", selection: $vm.selectedVoiceIdentifier) {
//                    ForEach(personalVoices, id: \.self) { voice in
//                        Button {
//                            vm.selectedVoiceIdentifier = voice.identifier
//                        } label: {
//                            Text(voice.name)
//                        }
//                    }
//                }
//            }
//        }
////            header: {
////                Text("Personal Voice")
////            }
//        footer: {
//            Text("To manage, go to Settings > Accessiblity > Personal Voice.")
////                Text("Personal Voices: \(personalVoices.count)")
//        }
//        .task {
//            if vm.usePersonalVoice == true {
//                await fetchPersonalVoices()
//            }
//        }
////            .onAppear {
////                if AVSpeechSynthesizer.personalVoiceAuthorizationStatus == .denied {
////                    vm.usePersonalVoice = false
////                }
////            }
////            .onChange(of: vm.selectedVoiceIdentifier) { _ in
//////                vm.assignVoice()
////            }
//        .onChange(of: vm.usePersonalVoice) { toggle in
//            if toggle == false {
//                vm.selectedVoiceIdentifier = nil
//            } else {
//                Task { await fetchPersonalVoices() }
//            }
//        }
////            .sheet(isPresented: $showingAppRestartInstructions) {
////                SafariView(url: URL(string: "https://support.apple.com/guide/iphone/quit-and-reopen-an-app-iph83bfec492/ios")!)
////                    .edgesIgnoringSafeArea(.bottom)
////            }
////        .alert("Personal Voice Unavailable", isPresented: $showingPersonalVoiceAlert) {
////            Button("Learn More") { showingpersonalVoiceSetupSheet = true }
////            Button("OK") { vm.usePersonalVoice = false }
////        } message: {
////            Text("It looks like you don't have any Personal Voices. To learn more about Personal Voice, tap \"Learn More\".")
////        }
////            .alert(isPresented: $showingRestartAlert) {
////                Alert(title: Text("Restart Required"),
////                      message: Text("To use Personal Voice, please quit and reopen the app."),
////                      // This closes/crashes the app, so Personal Voices can be fetched on the next launch. I don't like this solution, but the alternative is to have the user force-quit and reopen the app, which is a worse experience for them.
////                      primaryButton: .destructive(Text("Close App"), action: { fatalError() }),
////                      secondaryButton: .cancel(Text("OK"))
////                )
////            }
//    }
//    
//    @available(iOS 17, *)
//    func fetchPersonalVoices() async {
//        if AVSpeechSynthesizer.personalVoiceAuthorizationStatus == .authorized {
//            personalVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.voiceTraits.contains(.isPersonalVoice) }
//            
//            if vm.selectedVoiceIdentifier == nil {
//                if let voice = personalVoices.first {
//                    vm.selectedVoiceIdentifier = voice.identifier
//                }
//            }
//        }
//        
////        AVSpeechSynthesizer.requestPersonalVoiceAuthorization() { status in
////            if status == .authorized {
////                personalVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.voiceTraits.contains(.isPersonalVoice) }
////                
////                if vm.selectedVoiceIdentifier == nil {
////                    if let voice = personalVoices.first {
////                        vm.selectedVoiceIdentifier = voice.identifier
////                    }
////                }
////            }
////        }
//    }
//    
////    @available(iOS 17, *)
////    func checkPersonalVoiceStatus() {
////        if vm.usePersonalVoice == false {
////            vm.selectedVoiceIdentifier = nil
////        } else {
////            switch AVSpeechSynthesizer.personalVoiceAuthorizationStatus {
////            case .notDetermined, .authorized:
////                Task { await fetchPersonalVoices() }
////            default:
////                showingPersonalVoiceAlert = true
////            }
////        }
////    }
////    
////    @available(iOS 17, *)
////    func requestPersonalVoiceAuthorization() {
////        AVSpeechSynthesizer.requestPersonalVoiceAuthorization { status in
////            if status == .authorized {
////                print("I'm authorized to use Personal Voice!")
////                showingRestartAlert = true
////            } else {
////                print("Personal Voice not authorized")
////                vm.usePersonalVoice = false
////            }
////        }
////    }
//}
//
//#Preview {
//    if #available(iOS 17, *) {
//        PersonalVoiceSettingsView(showingpersonalVoiceSetupSheet: .constant(false))
//            .environmentObject(ViewModel())
//    } else {
//        EmptyView()
//    }
//}
