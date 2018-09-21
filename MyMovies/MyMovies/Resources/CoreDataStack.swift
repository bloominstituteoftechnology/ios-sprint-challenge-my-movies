//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Dillon McElhinney on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

import CoreData

/// Utility class for dealing with the CoreData stack
class CoreDataStack {
    static let shared = CoreDataStack()
    
    func save(context: NSManagedObjectContext) throws {
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
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var mainContext: NSManagedObjectContext  {
        return container.viewContext
    }
}
