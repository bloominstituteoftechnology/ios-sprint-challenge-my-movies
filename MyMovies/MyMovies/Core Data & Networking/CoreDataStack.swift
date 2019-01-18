//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Austin Cole on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    let container: NSPersistentContainer
    let mainContext: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "MyMovies")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("could not load the data store: \(error)")
            } else {
                print("\(description)")
            }
        }
        mainContext = container.viewContext
        mainContext.automaticallyMergesChangesFromParent = true
    }
}
