//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Jesse Ruiz on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension MyMovies {
    
    var movieRepresentation: MovieRepresentation? {
        
        guard let title = title,
            let identifier = identifier else { return nil }
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    @discardableResult convenience init(title: String,
                                        hasWatched: Bool,
                                        identifier: UUID = UUID(),
                                        context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext) {
        
        guard let hasWatched = movieRepresentation.hasWatched,
            let identifier = movieRepresentation.identifier else { return nil }
        
        self.init(title: movieRepresentation.title,
                  hasWatched: hasWatched,
                  identifier: identifier,
                  context: context)
    }
}
