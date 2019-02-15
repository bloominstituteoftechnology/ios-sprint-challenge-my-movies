//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Angel Buenrostro on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    private init() { }
    static let shared = CoreDataStack() // singleton, because there should only ever be ONE core data stack so singleton makes sense
    
    lazy var container: NSPersistentContainer = {
        
        // Give the container the name of your data model file, just using kCFBundleNameKey so we can save this code as a reusable snippet for other projects
        let container = NSPersistentContainer(name: "MyMovies" as String)
        
        // Load the persistent store
        container.loadPersistentStores{ (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // This should help you remember that the viewContext should be used on the main thread
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        return container.newBackgroundContext()
    }
    
}

