//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Mark Gerrior on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    /// Singleton. Only do once. Sharing state. Not _that_ expensive.
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movies")
        container.loadPersistentStores { _, error  in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        
        /// This is required for the viewContext (ie. the main context) to be updated with changes saved in a background context. In this case, the viewContext's parent is the persistent store coordinator, not another context. This will ensure that the viewContext gets the changes you made on a background context so the fetched results controller can see those changes and update the table view automatically.
// FIXME:        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }

    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        var error: Error?
        context.performAndWait {
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        /// Code will not excute until performAndWait is done.
        if let error = error { throw error }
    }
}
