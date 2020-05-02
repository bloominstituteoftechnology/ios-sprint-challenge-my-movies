//
//  CoreDataManager.swift
//  MyMovies
//
//  Created by Shawn James on 5/2/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    // this is how you make a core data stack
    
    // create singleton
    static let shared = CoreDataManager()
    
    // create container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movie")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    // create context -> everything done in the app uses the context
    var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
}
