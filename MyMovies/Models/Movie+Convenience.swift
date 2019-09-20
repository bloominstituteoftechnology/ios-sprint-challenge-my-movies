//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Andrew Ruiz on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    @discardableResult convenience init(title: String,
                                        identifier: UUID,
                                        hasWatched: Bool,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext) {
        
        guard let identifier = movieRepresentation.identifier,
            let title = movieRepresentation.title,
            let hasWatched = movieRepresentation.hasWatched else { return nil }
        
        self.init(title: title, identifier: identifier, hasWatched: hasWatched, context: context)
    }
    
    var movieRepresentation: MovieRepresentation {
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
}
