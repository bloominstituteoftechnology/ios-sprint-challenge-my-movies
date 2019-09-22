//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Alex Shillingford on 9/20/19.
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
    
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext) {
        
        guard let identifier = movieRepresentation.identifier else { return nil }
        
        self.init(title: movieRepresentation.title,
                  identifier: identifier,
                  hasWatched: movieRepresentation.hasWatched ?? false,
                  context: context)
    }
}
