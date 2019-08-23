//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Alex Shillingford on 8/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

import CoreData

// Contain all of the setup of the NSPersistentContainer
class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        // Give the container the name of the data model file
        let container = NSPersistentContainer(name: "identifier")
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        })
        
        return container
    }()
    
    // This should help you remember to use the viewContext on the main queue only.
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
}
