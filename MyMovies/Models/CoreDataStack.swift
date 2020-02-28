//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by scott harris on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    var mainContext: NSManagedObjectContext {
        return containter.viewContext
    }
    
    lazy var containter: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "MyMovies")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persitent stores: \(error)")
            }
        }
        return container
    }()
}
