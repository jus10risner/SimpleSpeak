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
    
    @State private var showingMailError = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Speech") {
                    NavigationLink {
                        VoiceSelectionView()
                    } label: {
                        HStack {
                            Label("Voice", systemImage: "person.wave.2")
                            
                            Spacer()
                            
                            Text(selectedVoice)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    
                    Picker(selection: $vm.cellWidth) {
                        ForEach(PhraseCellWidthOptions.allCases, id: \.self) {
                            Text(String(describing: $0).capitalized)
                        }
                    } label: {
                        Label("Phrase Buttons", systemImage: "rectangle.grid.2x2")
                    }
                    
//                    Toggle(isOn: $vm.useDuringCalls, label: {
//                        Label("Use During Calls", systemImage: "phone")
//                    })
//                    .tint(Color(.defaultAccent))
                }
//                header: {
//                    Text("Speech")
//                } footer: {
//                    Text("Sends speech to other participants during phone calls and FaceTime.")
//                }
                
                Section("Appearance") {
                    NavigationLink {
                        // App Icon selector
                    } label: {
                        Label("App Icon", systemImage: "app.badge")
                    }
                    
                    Picker(selection: $vm.appAppearance) {
                        ForEach(AppearanceOptions.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    } label: {
                        Label("Theme", systemImage: "circle.lefthalf.filled")
                    }
//                    .pickerStyle(.navigationLink)
                    .onChange(of: vm.appAppearance) { _ in
                        AppearanceController.shared.setAppearance()
                    }
                }
                
                Section("More") {
                    contactButton
                    
                    Button {
                        // App Store rating link
                    } label: {
                        Label("Rate on the App Store", systemImage: "star")
                    }
                    
                    Button {
                        // ShareLink
                    } label: {
                        Label("Share SimpleSpeak", systemImage: "square.and.arrow.up")
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationBarTitleDisplayMode(.inline)
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
        .alert("Could not send mail", isPresented: $showingMailError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\nPlease make sure email has been set up on this device, then try again.")
        }
    }
    
    private var selectedVoice: String {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let selectedVoice = voices.first(where: { $0.identifier == vm.selectedVoiceIdentifier })
        
        return selectedVoice?.name ?? "Unknown"
    }
    
    // Launches Mail Composer, if email has been set up
    private var contactButton: some View {
        Button {
            let composeVC = MailComposeViewController.shared
            
            if composeVC.canSendEmail == true {
                // Composes an email message, and prefills email address
                composeVC.sendEmail()
            } else {
                showingMailError = true
            }
        } label: {
            Label("Contact", systemImage: "envelope")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ViewModel())
}
