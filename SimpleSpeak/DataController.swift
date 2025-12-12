//
//  DataController.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 6/18/24.
//

import CoreData
import SwiftUI

class DataController: ObservableObject {
    // A singleton for the entire app to use
    static let shared = DataController()
    
    // Properties to be passed to other views, for toggling
    var isShowingDataError: Bool = false

    // MARK: - Persistent container
    let container: NSPersistentCloudKitContainer

    // MARK: - Preview / Unit Test instances
    static let preview: DataController = DataController(inMemory: true)

    static let unitTest: DataController = DataController(inMemory: true)
    
    // MARK: - Initializer
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "SimpleSpeakDataModel")

        if inMemory {
            // Preview / unit test store
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve persistent store description")
        }

        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        if !inMemory, FileManager.default.ubiquityIdentityToken != nil {
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.risner.justin.SimpleSpeak"
            )
        } else if !inMemory {
            description.cloudKitContainerOptions = nil
            print("⚠️ CloudKit unavailable — using local store only")
        }

        // ✅ Load store synchronously so local data is immediately available
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("❌ Failed to load persistent store:", error)
            } else {
                print("✅ Loaded persistent store: \(storeDescription.url?.absoluteString ?? "")")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true

        // Async CloudKit schema initialization for debug
        #if DEBUG
        if description.cloudKitContainerOptions != nil {
            Task {
                do {
                    try container.initializeCloudKitSchema(options: [])
                    print("✅ CloudKit schema initialized")
                } catch {
                    print("❌ Unable to initialize CloudKit schema:", error)
                }
            }
        }
        #endif
    }
    
    // If there are any changes, attempt to save
    func save() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch let error {
            self.isShowingDataError = true
            print("⚠️ Failed to save Core Data context: \(error.localizedDescription)")
        }
    }
}
