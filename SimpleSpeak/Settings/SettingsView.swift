//
//  SettingsView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 6/19/24.
//

import AVFoundation
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: ViewModel
    
    @State private var showingMailError = false
    let appStoreURL: URL = URL(string: "https://apps.apple.com/app/id6743131751")!
    let ratingURL: URL = URL(string: "https://apps.apple.com/app/id6743131751?action=write-review")!
    
    var body: some View {
        NavigationStack {
            List {
                Section {
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
                    
                    Toggle(isOn: $vm.useDuringCalls, label: {
                        Label("Use During Calls", systemImage: "phone")
                    })
                    .tint(Color(.accent))
                } header: {
                    Text("Speech")
                } footer: {
                    Text("Send speech to other participants on calls.")
                }
                
                Section("Appearance") {
                    NavigationLink {
                        AppIconSelectorView()
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
                    .onChange(of: vm.appAppearance) {
                        AppearanceController.shared.setAppearance()
                    }
                    
                    Picker(selection: $vm.cellWidth) {
                        ForEach(PhraseCellWidthOptions.allCases, id: \.self) { option in
                            Text(String(describing: option).capitalized)
                        }
                    } label: {
                        Label("Phrase Button Size", systemImage: "rectangle.grid.2x2")
                    }
                    
                    Picker(selection: $vm.selectedFont) {
                        ForEach(FontOption.allCases) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    } label: {
                        Label("Phrase Text Size", systemImage: "textformat.size")
                    }
                }
                
                Section {
                    contactButton
                    
                    Link(destination: ratingURL) {
                        Label("Rate on the App Store", systemImage: "star")
                    }
                  
                    ShareLink(item: appStoreURL) {
                        Label("Share SimpleSpeak", systemImage: "square.and.arrow.up")
                    }
                } header: {
                    Text("More")
                } footer: {
                    Text("Version \(AppInfo.shared.version)")
                }
                .buttonStyle(.plain)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "xmark")
                            .labelStyle(.adaptive)
                    }
                }
            }
        }
        .alert("Mail account not found", isPresented: $showingMailError) {
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
