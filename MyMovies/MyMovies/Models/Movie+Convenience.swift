//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Sean Acres on 7/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    @discardableResult convenience init(title: String, hasWatched: Bool, identifier: UUID = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        // Set up NSManagedObject part of the class
        self.init(context: context)
        
        // Set up the unique parts of the Entry class
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.title = movieRepresentation.title
        self.hasWatched = movieRepresentation.hasWatched ?? false
        self.identifier = movieRepresentation.identifier
    }
    
    var movieRepresentation: MovieRepresentation {
        return MovieRepresentation(title: title!, identifier: identifier, hasWatched: hasWatched)
    }
}
