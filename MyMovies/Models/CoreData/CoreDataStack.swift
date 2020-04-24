//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Shawn James on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
        
    // create singleton
    static let shared = CoreDataStack()
    
    // create container
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyMovies")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // create context -> everything done in the app uses the context
    var mainContext: NSManagedObjectContext {
        container.viewContext
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
