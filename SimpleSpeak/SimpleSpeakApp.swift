//
//  SimpleSpeakApp.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 5/8/23.
//

import AVFoundation
import SwiftUI

@main
struct SimpleSpeakApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var vm = ViewModel()
    let dataController = DataController.shared
    
    init() {
        // Tints alert buttons throughout the app
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color(.defaultAccent))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(vm)
                .task { AppearanceController.shared.setAppearance() }
        }
        .onChange(of: scenePhase) { _ in
            dataController.save()
        }
        .onChange(of: AVSpeechSynthesisVoice.speechVoices().count) { newPhase in
            Task { @MainActor in
                await vm.checkSpeechVoice()
            }
        }
    }
}
