//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Seschwan on 7/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movie")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                
            }
        })
        return container
    }()
    var mainContext: NSManagedObjectContext {
        return self .container.viewContext
    }
}
