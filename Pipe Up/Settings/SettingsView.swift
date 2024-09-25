//
//  SettingsView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/19/24.
//

//import AVFoundation
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $vm.useDuringCalls, label: {
                        Label("Use During Calls", systemImage: "phone.fill")
                    })
                } footer: {
//                    Text("Determines whether your typed phrases are spoken aloud to the other party on a phone call.")
                    Text("Allows this app to send your spoken audio to other parties on a phone call or FaceTime.")
                }
                
                PersonalVoiceSettingsView()
                
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

#Preview {
    SettingsView()
        .environmentObject(ViewModel())
}
