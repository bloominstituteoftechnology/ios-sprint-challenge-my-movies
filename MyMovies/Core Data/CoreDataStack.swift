//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Michael Flowers on 10/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    //create the persistentContainer
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movie")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("Error failed to load persistent stores: \(error)")
            }
        }
        //because we want to use another context we have to state how we want the two to communicate
        container.viewContext.automaticallyMergesChangesFromParent = true //the psc will be the parent
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    //Because context's need to be handled on the same queue/thread, and because they should be only handled/changed/modified inside of a perform block, we create this function to handle those situations later on in the code.
    func save(context: NSManagedObjectContext) throws {
        var error: Error?
        
        context.performAndWait {
            
            do {
                try context.save()
            } catch let saveError {
                print("Error saving to generic context: \(saveError)")
                //if we get an error assign it to the error above
                error = saveError
            }
        }
        
    
        //if it throw an error, we assigned it to this placeholder error and now we want to check to see if it is indeed an error and if so, throw that error out the window.
        if let error = error {
            throw error
        }
    }
}
