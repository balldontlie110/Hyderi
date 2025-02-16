//
//  CoreDataManager.swift
//  Hyderi
//
//  Created by Ali Earp on 12/15/24.
//

import CoreData

struct CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "HyderiApp")
        
        if let appGroup = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Ali.Hyderi") {
            let store = appGroup.appendingPathComponent("HyderiApp.sqlite")
            
            container.persistentStoreDescriptions.first?.url = store
        }
        
        container.loadPersistentStores { description, error in
            if let error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
}
