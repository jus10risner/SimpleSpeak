//
//  ContentView.swift
//  QuickSpeak
//
//  Created by Justin Risner on 5/8/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var haptics = HapticsManager()
    
    var body: some View {
        CommunicationView()
            .environmentObject(haptics)
    }
}

#Preview {
    ContentView()
}
