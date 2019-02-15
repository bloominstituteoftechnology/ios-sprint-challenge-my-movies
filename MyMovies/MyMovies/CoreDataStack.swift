//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Jocelyn Stuart on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    private init() { }
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        // Create a PersistentContainer
        let appName = Bundle.main.object(forInfoDictionaryKey: (kCFBundleNameKey as String)) as! String
        
        let container = NSPersistentContainer(name: appName)
        
        // Load its PersistenStores
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // Also create a helper variable
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        return container.newBackgroundContext()
    }
}
