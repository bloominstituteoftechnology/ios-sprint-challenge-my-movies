//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Joe Veverka on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    // MARK: - Properties
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movie")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
            
        }
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    var backGroundContext: NSManagedObjectContext {
        return container.newBackgroundContext()
    }
    
    // MARK: - Update/Save func
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        var error: Error?
        context.performAndWait {
            do {
                try context.save()
            } catch let saveError {
                context.reset()
                error = saveError
                print("Error Saving: \(String(describing: error))")
            }
        }
    }
}
