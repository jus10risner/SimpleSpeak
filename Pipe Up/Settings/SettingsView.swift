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
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        VoiceSelectionView()
                    } label: {
                        HStack {
                            Label("Speech Voice", systemImage: "person.wave.2.fill")
                            
                            Spacer()
                            
                            Text(selectedVoice)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    
//                    Toggle(isOn: $vm.useDuringCalls, label: {
//                        Label("Use During Calls", systemImage: "phone.fill")
//                    })
                }
//                header: {
//                    Text("Speech")
//                } footer: {
//                    Text("Sends speech to other participants during phone calls and FaceTime.")
//                }
                
                Section {
                    Picker(selection: $vm.appAppearance) {
                        ForEach(AppearanceOptions.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    } label: {
                        Label("App Theme", systemImage: "circle.lefthalf.filled")
                    }
                    .pickerStyle(.navigationLink)
                    .onChange(of: vm.appAppearance) { _ in
                        AppearanceController.shared.setAppearance()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
//            .sheet(isPresented: $showingPersonalVoiceSetupSheet, content: {
//                webView(url: URL(string: "https://support.apple.com/104993")!, title: "Personal Voice", selection: $showingPersonalVoiceSetupSheet)
//            })
//            .sheet(isPresented: $showingVoiceSelectionSheet, content: {
//                webView(url: URL(string: "https://support.apple.com/111798")!, title: "Voice Selection", selection: $showingVoiceSelectionSheet)
//            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.heavy)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Dismiss", systemImage: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title2)
                            .foregroundStyle(Color.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var selectedVoice: String {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let selectedVoice = voices.first(where: { $0.identifier == vm.selectedVoiceIdentifier })
        
        return selectedVoice?.name ?? "Unknown"
    }
    
//    private func webView(url: URL, title: String, selection: Binding<Bool>) -> some View {
//        NavigationStack {
//            WebView(url: url)
//                .ignoresSafeArea(edges: .bottom)
//                .navigationTitle(title)
//                .navigationBarTitleDisplayMode(.inline)
//                .toolbar {
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Button("Done") {
//                            selection.wrappedValue = false
//                        }
//                    }
//                }
//        }
//    }
}

#Preview {
    SettingsView()
        .environmentObject(ViewModel())
}
