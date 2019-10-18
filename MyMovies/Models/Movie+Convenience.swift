//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Isaac Lyons on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import CoreData

extension Movie {
    
    var representation: MovieRepresentation? {
        guard let title = title else {
                return nil
        }
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    @discardableResult convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext) {
        if let identifier = movieRepresentation.identifier,
            let hasWatched = movieRepresentation.hasWatched {
            self.init(title: movieRepresentation.title,
                      identifier: identifier,
                      hasWatched: hasWatched,
                      context: context)
        } else {
            self.init(title: movieRepresentation.title,
                      context: context)
        }
        
        
    }
    
}
