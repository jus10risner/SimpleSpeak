//
//  ContentView.swift
//  QuickSpeak
//
//  Created by Justin Risner on 5/8/23.
//

import SwiftUI

struct ContentView: View {
//    @StateObject var vm = ViewModel()
//    @State private var selectedTab = 1
    
    var body: some View {
        CommunicationView()
//        TabView(selection: $selectedTab)  {
//            CommunicationView()
//                .tabItem { Label("Speak", systemImage: "person.wave.2") }
//                .tag(1)
//            
//            CategoriesListView()
//                .tabItem { Label("Phrases", systemImage: "bookmark") }
//                .tag(2)
//            
//            SettingsView()
//                .tabItem { Label("Settings", systemImage: "gearshape") }
//                .tag(3)
//            
//        }
//        .tint(Color("AccentColor"))
//        .environmentObject(vm)
    }
}

#Preview {
    let controller = DataController(inMemory: true)
    let context = controller.container.viewContext
    
    return ContentView()
        .environment(\.managedObjectContext, context)
        .environmentObject(ViewModel())
}
