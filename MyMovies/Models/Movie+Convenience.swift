//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Breena Greek on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    @discardableResult convenience init(title: String,
                                        identifier: UUID = UUID(),
                                        hasWatched: Bool = false,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        guard let identifier = movieRepresentation.identifier else {
            return nil
        }
        
        self.init(title: movieRepresentation.title,
                  identifier: identifier,
                  hasWatched: movieRepresentation.hasWatched ?? false)
    }
        
        var movieRepresentation: MovieRepresentation? {
            guard let title = title,
                    let identifier = identifier else { return nil }
        
        return MovieRepresentation(title: title,
                                   identifier: identifier,
                                   hasWatched: hasWatched)
    }
}

