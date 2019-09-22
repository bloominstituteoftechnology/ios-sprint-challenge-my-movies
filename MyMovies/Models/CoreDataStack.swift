//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Alex Shillingford on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

// Contain all of the setup of the NSPersistentContainer
class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        // Give the container the name of the data model file
        let container = NSPersistentContainer(name: "Movie")
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // This should help you remember to use the viewContext on the main queue only.
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            do {
                try context.save()
            } catch {
                NSLog("Error saving context on line \(#line) in file \(#file): \(error)")
                context.reset()
            }
        }
    }
}
