//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Nichole Davidson on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movie")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true // default value is false. when the background queue makes changes this will let the other queue know what's going on. merges any changes that come from the parent
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
}
