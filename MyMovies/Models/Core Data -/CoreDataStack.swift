//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Elizabeth Wingate on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataStack {
    
    static let shared = CoreDataStack()
      let container: NSPersistentContainer
      
      let mainContext: NSManagedObjectContext
      
      init() {
        container = NSPersistentContainer(name: "MyMovies")
          
        container.loadPersistentStores { (description, error) in
          if let e = error {
            fatalError("Couldn't load the data store: \(e)")
        }
    }
        mainContext = container.viewContext
  }
}
