//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Eoin Lavery on 25/02/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movies")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("Error loading persistent store(s): \(error)")
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
            } catch let caughtError {
                error = caughtError
            }
        }
        
        if error != nil {
            throw error!
        }
    }
    
}
