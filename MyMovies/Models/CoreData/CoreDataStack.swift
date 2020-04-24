//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Harmony Radley on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    //Singleton
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movie")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        
        return container
    }()
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
}
