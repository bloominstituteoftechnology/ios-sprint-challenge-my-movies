//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by brian vilchez on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataTask {
    
    //MARK: - properties
    static let shared = CoreDataTask()
    
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movies")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                NSLog("failed to load from persistence store: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
      return container.viewContext
    }
}
