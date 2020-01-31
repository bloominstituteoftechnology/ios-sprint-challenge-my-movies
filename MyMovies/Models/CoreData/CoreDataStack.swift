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
    static let shared = CoreDataStack()
    private let modelName = "MyMovies"
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
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
    
    //MARK: Update
    /**
     Saves whatever changes are in the context that's passed in (default is mainContext)
     */
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            do {
                try context.save()
            } catch {
                context.reset()
                NSLog("Saving Task failed with error: \(error)")
            }
        }
    }
}
