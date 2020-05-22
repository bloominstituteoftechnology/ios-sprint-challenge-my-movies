//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Nonye on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

// MARK: - MOVIE EXTENSTION

extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        guard let id = identifier,
            let title = title else {
                return nil
        }
        
        return MovieRepresentation(identifier: id.uuidString, title: title, hasWatched: hasWatched)
    }
    
    @discardableResult convenience init(title: String,
                                        hasWatched: Bool = false,
                                        identifier: UUID = UUID(),
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        guard let identifier = UUID(uuidString: movieRepresentation.identifier)
            else { return nil }
        
        self.init(title: movieRepresentation.title,
                  hasWatched: movieRepresentation.hasWatched,
                  identifier: identifier, context: context)
    }
}



