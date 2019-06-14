//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by John Pitts on 6/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ios-sprint-challenge-my-movies")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    
    var mainContext: NSManagedObjectContext  {
        return container.viewContext
    }
}
