//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Joshua Sharp on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {
    }
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: coreDataModelName)
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Unable to load persistent store! Error: \(error)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            do {
                try context.save()
            } catch {
                NSLog("Error saving context: \(error)")
                context.reset()
            }
        }
    }
}
