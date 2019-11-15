//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by morse on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    // This initializer sets up the Core Data (NSManagedObject) part of the Task, then gives it the properties unique to a Task entity.
    
    @discardableResult convenience init(title: String,
                                        hasWatched: Bool = false,
                                        identifier: UUID = UUID(),
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        // Calling the designated initializer
        self.init(context: context)
        
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(title: movieRepresentation.title,
                  hasWatched: movieRepresentation.hasWatched ?? false,
                  identifier: movieRepresentation.identifier ?? UUID(),
                  context: context)
    }
    
    var movieRepresentation: MovieRepresentation? {
        
        guard let title = title else { return nil }
        
        return MovieRepresentation(title: title,
                                   identifier: identifier, hasWatched: hasWatched)
    }
}
