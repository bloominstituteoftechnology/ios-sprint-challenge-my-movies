//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Andrew Liao on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    let container:NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movie")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Error loading persistent store")
            }
        })
        return container
    }()
    
    var mainContext:NSManagedObjectContext {
        return container.viewContext
    }
}
