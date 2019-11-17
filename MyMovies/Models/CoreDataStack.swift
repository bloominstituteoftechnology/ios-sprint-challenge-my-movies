//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by BDawg on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {  // NSPersisitentContainer is a SQLite DB.
        let container = NSPersistentContainer(name: "Movies")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save(context: NSManagedObjectContext) throws {
        var error: Error?
        
        context.performAndWait {
            do {
                try context.save() // Context is a holding area for changed items, getting ready to be saved/commited.  Scratchpad.
            } catch let saveError {
                error = saveError
            }
        }
        
        if let error = error { throw error }
    }
}
