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
    
    @State private var showingPersonalVoiceSetupSheet = false
    @State private var showingVoiceSelectionSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $vm.useDuringCalls, label: {
                        Label("Use During Calls", systemImage: "phone.fill")
                    })
                } footer: {
                    Text("Sends speech to other parties on a phone call or FaceTime.")
                }
                
                if #available(iOS 17, *) {
//                    if AVSpeechSynthesizer.personalVoiceAuthorizationStatus == .authorized {
                    PersonalVoiceSettingsView(showingpersonalVoiceSetupSheet: $showingPersonalVoiceSetupSheet)
//                    }
                }
                
                Button("Change your speech voice") {
                    showingVoiceSelectionSheet = true
                }
                
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
            .tint(Color(.defaultAccent))
//            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingPersonalVoiceSetupSheet, content: {
                webView(url: URL(string: "https://support.apple.com/en-us/104993")!, title: "Personal Voice", selection: $showingPersonalVoiceSetupSheet)
            })
            .sheet(isPresented: $showingVoiceSelectionSheet, content: {
                webView(url: URL(string: "https://support.apple.com/en-us/111798")!, title: "Voice Selection", selection: $showingVoiceSelectionSheet)
            })
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
    
    private func webView(url: URL, title: String, selection: Binding<Bool>) -> some View {
        NavigationStack {
            WebView(url: url)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            selection.wrappedValue = false
                        }
                    }
                }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ViewModel())
}
