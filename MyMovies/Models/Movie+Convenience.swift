//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Mark Poggi on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        guard let id = identifier, let title = title else { return nil
                
        }
        
        return MovieRepresentation(title: title,
                                   identifier: id,
                                   hasWatched: hasWatched)
    }
    
    @discardableResult convenience init(identifier: UUID = UUID(),
                     title: String,
                     hasWatched: Bool = false,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifier = movieRepresentation.identifier else { return nil }
        
        self.init(identifier: identifier,
                  title: movieRepresentation.title,
                  hasWatched: movieRepresentation.hasWatched ?? false,
                  context: context)
    }
}

