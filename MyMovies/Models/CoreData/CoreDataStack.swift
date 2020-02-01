//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Kenny on 1/31/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    //MARK: Properties
    static let shared = CoreDataStack()
    let modelname = "MyMovies"
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelname)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load persistent stores \(error)")
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        return container.newBackgroundContext()
    }
    //MARK: Update
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        var error: Error?
        context.performAndWait {
            do {
                try context.save()
            } catch let saveError {
                context.reset()
                error = saveError
                print("error saving: \(String(describing: error))")
            }
        }
        //if let error = error {throw error}
    }
}

