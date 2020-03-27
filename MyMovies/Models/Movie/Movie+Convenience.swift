//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Shawn Gee on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String, hasWatched: Bool = false, identifier: UUID = UUID(), context: NSManagedObjectContext) {
        self.init()
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier.uuidString
    }
    
    convenience init?(_ movieRepresentation: MovieRepresentation, context: NSManagedObjectContext) {
        guard let idString = movieRepresentation.identifier,
        let id = UUID(uuidString: idString) else {
            return nil
        }
        
        self.init(title: movieRepresentation.title,
                  hasWatched: movieRepresentation.hasWatched ?? false,
                  identifier: id,
                  context: context)
    }
    
    var movieRepresentation: MovieRepresentation {
        MovieRepresentation(title: self.title, identifier: self.identifier, hasWatched: self.hasWatched)
    }
}
