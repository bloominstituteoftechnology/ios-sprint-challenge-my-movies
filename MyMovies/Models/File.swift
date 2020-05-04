//
//  File.swift
//  MyMovies
//
//  Created by David Williams on 5/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    // This is a shared instance of the Core Data Stack
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        // change the name to your data model file
        let container = NSPersistentContainer(name: "Movie")
        container.loadPersistentStores { (_, error) in
            if let error = error {
            fatalError("Fail to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // Makes the access to the context faster
    // Reminds you to use the context on the main queue
    
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
           
           if let error = error {
               throw error
           }
       }
}
