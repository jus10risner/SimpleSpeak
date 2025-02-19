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

    // A test configuration for SwiftUI previews
    static var preview: DataController = {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create example phrase.
        let phrase = SavedPhrase(context: viewContext)
        phrase.text = "Hello, my name is John"

        return controller
    }()
    
    // A configuration, specifically for use in unit tests
//    static let unitTest: DataController = {
//        let controller = DataController(inMemory: true)
//        // empty data store
//        return controller
//    }()
    
    // Storage for Core Data. Sets the appropriate persistent container.
//    lazy var container: NSPersistentCloudKitContainer = {
    lazy var container: NSPersistentContainer = {
//        container = NSPersistentCloudKitContainer(name: "SimpleSpeakDataModel")
        container = NSPersistentContainer(name: "SimpleSpeakDataModel")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("###\(#function): Failed to retrieve a persistent store description.")
        }
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
//        if cloudContainerAvailable == true {
//            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.risner.justin.SocketCD")
//        } else {
//            description.cloudKitContainerOptions = nil
//        }

        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                self.isShowingDataError = true
                print("Unresolved error: \(error.localizedDescription), \(error.userInfo)")
            } else {
                print("Loaded Core Data!")
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
//        container.viewContext.undoManager = UndoManager()
        
//        #if DEBUG
//        do {
//            // Use the container to initialize the development schema.
//            try container.initializeCloudKitSchema(options: [])
//        } catch {
//            // Handle any errors.
//            print("Unable to initialize CloudKit schema: \(error.localizedDescription)")
//        }
//        #endif
        
        return container
    }()
    
    // An initializer to load Core Data, optionally able to use an in-memory store.
    init(inMemory: Bool = false) {
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
    }
    
    // Checks to see if an iCloud container is available on the device
//    var cloudContainerAvailable: Bool {
//        if let _ = FileManager.default.ubiquityIdentityToken {
//            return true
//        } else {
//            return false
//        }
//    }
    
    // If there are any changes, attempt to save
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                self.isShowingDataError = true
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
