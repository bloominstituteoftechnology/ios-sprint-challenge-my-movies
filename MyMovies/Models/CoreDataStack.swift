//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Tobi Kuyoro on 31/01/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    private init() {}
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movies")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load movies from persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            do {
                try CoreDataStack.shared.mainContext.save()
            } catch {
                NSLog("Error saving context: \(error)")
                CoreDataStack.shared.mainContext.reset()
            }
        }
    }
}
