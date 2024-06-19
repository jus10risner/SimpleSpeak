//
//  ContentView.swift
//  QuickSpeak
//
//  Created by Justin Risner on 5/8/23.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab)  {
            CommunicationView()
                .tabItem { Label("Communicate", systemImage: "person.wave.2") }
                .tag(1)
            
            SavedPhrasesView()
                .tabItem { Label("Saved Phrases", systemImage: "bookmark") }
                .tag(2)
            
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
}
