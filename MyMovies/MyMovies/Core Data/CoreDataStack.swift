//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Michael Flowers on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movie")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("Error failed to load persistent stores: \(error)")
            }
        }
        //because we want to use another context we have to state how we want the two to communicate
        //        container.viewContext.automaticallyMergesChangesFromParent = true //the psc will be the parent
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    //create a generic save context function
    func save(context: NSManagedObjectContext) throws {
        var error: Error?
        
        context.performAndWait {
            
            do {
                try context.save()
            } catch let saveError {
                print("Error saving to generic context: \(saveError)")
                error = saveError
            }
        }
        
        if let error = error {
            throw error
        }
    }
}
