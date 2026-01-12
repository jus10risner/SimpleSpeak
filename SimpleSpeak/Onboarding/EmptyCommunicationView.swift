//
//  EmptyCommunicationView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 2/18/25.
//

import CoreData
import SwiftUI

struct EmptyCommunicationView: View {
    @Binding var showingDefaultCategoriesSelector: Bool
    
    // Properties to track iCloud sync status
    @State private var iCloudDataImporting = false
    @State private var publisher = NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
    
    var body: some View {
        ContentUnavailableView {
            Label("Add a Custom Category", systemImage: "bookmark")
        } description: {
            Text("Tap the plus button above to get started.")
        } actions: {
            Button("Use Default Categories") { showingDefaultCategoriesSelector = true }
        }
        .overlay {
            VStack {
                if iCloudDataImporting {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        ProgressView()
                            .tint(Color.primary)
                        
                        Text("Checking for iCloud data")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(.bottom)
                }
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
    EmptyCommunicationView(showingDefaultCategoriesSelector: .constant(false))
}
