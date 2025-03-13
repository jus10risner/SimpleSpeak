//
//  EmptyCommunicationView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 2/18/25.
//

import CoreData
import SwiftUI

struct EmptyCommunicationView: View {
    @EnvironmentObject var onboarding: OnboardingManager
    @EnvironmentObject var vm: ViewModel
    
    @Binding var showingAddCategory: Bool
    @Binding var showingDefaultCategoriesSelector: Bool
    
    // Properties to track iCloud sync status
    @State private var iCloudDataImporting = false
    @State private var publisher = NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            HStack {
                Text("Tap")
                
                AddCategoryButton(action: { showingAddCategory = true })
                
                Text("to add a category")
            }
            .font(.title2.bold())
            .accessibilityElement()
            .accessibilityLabel("Tap Add Category to add your first category.")
            
            VStack {
                Text("Not sure where to start?")
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Use Default Categories") { showingDefaultCategoriesSelector = true }
            }
            
            Spacer()
        }
        .frame(width: 300)
        .overlay {
            VStack {
                if iCloudDataImporting && onboarding.isComplete == false {
                    VStack(spacing: 10) {
                        Text("Checking for iCloud data")
                            .font(.subheadline)
                        
                        ProgressView()
                    }
                    .foregroundStyle(Color.secondary)
                    .padding(.top)
                }
                
                Spacer()
            }
        }
        .onReceive(publisher) { notification in
            if let userInfo = notification.userInfo {
                if let event = userInfo["event"] as? NSPersistentCloudKitContainer.Event {
                    if event.type == .import {
                      iCloudDataImporting = true
                    } else {
                      iCloudDataImporting = false
                    }
                 }
              }
           }
    }
}

#Preview {
    EmptyCommunicationView(showingAddCategory: .constant(false), showingDefaultCategoriesSelector: .constant(false))
        .environmentObject(ViewModel())
}
