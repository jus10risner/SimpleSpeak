//
//  QuickSpeakApp.swift
//  QuickSpeak
//
//  Created by Justin Risner on 5/8/23.
//

import SwiftUI

@main
struct QuickSpeakApp: App {
    @Environment(\.scenePhase) var scenePhase
    let dataController = DataController.shared
    
    init() {
        // Tints alert buttons throughout the app
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color(.defaultAccent))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .task { AppearanceController.shared.setAppearance() }
        }
        .onChange(of: scenePhase) { _ in
            dataController.save()
        }
    }
}
