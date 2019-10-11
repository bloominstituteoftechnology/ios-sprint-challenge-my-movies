//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by brian vilchez on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    //MARK: - Properties
    static let shared = CoreDataStack()
    
    lazy var persistenContainer:NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyMovies")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("unable to load from persistence ")
            }
        })
        return container
    }()

    
    lazy var mainContext: NSManagedObjectContext = {
        return persistenContainer.viewContext
    }()
    
}

extension NSManagedObjectContext {
    func saveChanges() {
        if self.hasChanges {
            do {
                try save()
            } catch let error {
                NSLog("error saving to perssistent store: \(error)")
            }
        }
    }
}
