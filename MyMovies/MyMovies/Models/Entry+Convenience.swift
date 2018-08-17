//
//  Entry+Convenience.swift
//  MyMovies
//
//  Created by Vuk Radosavljevic on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Entry {
    
    convenience init(title: String, hasWatched: Bool = false, managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: managedObjectContext)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = UUID()
    }
    
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext) {
        self.init(title: movieRepresentation.title, managedObjectContext: context)
    }
    
}
