//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Jonathan T. Miles on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyMovies")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent store: \(error)")
            }
        })
        return container
    } ()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
}
