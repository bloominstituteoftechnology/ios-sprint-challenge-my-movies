//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by macbook on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData


extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        
        guard let title = title,
            let identifier = identifier else { return nil }
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
        
    }
    
    @discardableResult convenience init(title: String, hasWatched: Bool?, identifier: UUID? = UUID(), context: NSManagedObjectContext) {
        
        self.init(context: context)
        
        self.title = title
        self.hasWatched = hasWatched ?? false
        self.identifier = identifier
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext) {
        
        self.init(title: movieRepresentation.title,
                  hasWatched: movieRepresentation.hasWatched,
                  identifier: movieRepresentation.identifier,
                  context: context)
    }
    
}
