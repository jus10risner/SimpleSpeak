//
//  SimpleSpeakApp.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 5/8/23.
//

import AVFoundation
import SwiftUI
import TipKit

@main
struct SimpleSpeakApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var vm = ViewModel()
    let dataController = DataController.shared
    
    init() {
        // Tints alert buttons throughout the app
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color(.accent))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(vm)
                .task {
                    AppearanceController.shared.setAppearance()
                    
                    #if DEBUG
                    // Reset the datastore for testing purposes
                    try? Tips.resetDatastore()
                    #endif

                    // Configure TipKit
                    try? Tips.configure()
                }
        }
        .onChange(of: scenePhase) {
            dataController.save()
        }
        .onChange(of: AVSpeechSynthesisVoice.speechVoices().count) {
            Task { @MainActor in
                try await Task.sleep(for: .seconds(0.5))
                await vm.checkSpeechVoice()
            }
        }
    }
}
