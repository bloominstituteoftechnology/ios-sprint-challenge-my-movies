//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Chad Rutherford on 12/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import CoreData
import Foundation

class CoreDataStack {
    static let shared = CoreDataStack()
    
    var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movie")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error loading persistent stores: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
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
        
        if let error = error { throw error }
    }
}
