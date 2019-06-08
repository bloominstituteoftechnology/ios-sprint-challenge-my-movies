//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Alex on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {

    static let shared = CoreDataStack()
    
    var mainContext: NSManagedObjectContext  {
        return container.viewContext
    }

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movie")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("Failed to laod the persistent store: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    /// A generic function to save any context we want (main or background)
    func save(context: NSManagedObjectContext) throws {
        // A placeholder for the potential error we could get in this function if something doesn't work.
        var error: Error?
        context.performAndWait {
            do {
                try context.save()
            } catch let saveError {
                NSLog("Error saving moc: \(saveError)")
                error = saveError
            }
        }
        if let error = error { throw error }
    }
}
