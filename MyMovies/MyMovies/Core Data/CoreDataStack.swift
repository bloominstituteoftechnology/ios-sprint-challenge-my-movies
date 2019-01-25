//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Ivan Caldwell on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack{
    static let shared = CoreDataStack()
    let mainContext: NSManagedObjectContext
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "MyMovies")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("\nCoreDataStack.swift\nError: Could not load the data store. \n\(error)")
            } else {
                print (description)
            }
        }
        mainContext = container.viewContext
    }
}
