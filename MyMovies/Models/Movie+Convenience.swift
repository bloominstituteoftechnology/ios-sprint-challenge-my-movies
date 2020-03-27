//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Mark Gerrior on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

/// Because we choose class define in Movies.xcdaatamodeld, Movie gets generated behind the scenes
extension Movie {
    
    @discardableResult convenience init(identifier: UUID,
                     title: String,
                     hasWatched: Bool = false,
                     context: NSManagedObjectContext) {
        /// Magic happens here
        self.init(context: context)
        
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
    }
}

