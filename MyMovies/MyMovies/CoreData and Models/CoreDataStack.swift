//
//  File.swift
//  MyMovies
//
//  Created by Samantha Gatt on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Journal")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent store: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    static let moc = CoreDataStack.shared.mainContext
}
