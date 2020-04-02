//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by David Wright on 2/23/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData


extension Movie {
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        
        if identifier == nil {
            identifier = UUID()
        }
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    @discardableResult
    convenience init(title: String,
                     identifier: UUID = UUID(),
                     hasWatched: Bool = false,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    @discardableResult
    convenience init?(movieRepresentation: MovieRepresentation,
                      context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
                      let hasWatched = movieRepresentation.hasWatched ?? false
                      let movieIdentifier = movieRepresentation.identifier ?? UUID()
        
        
        
        self.init(title: movieRepresentation.title,
                  identifier: movieIdentifier,
                  hasWatched: hasWatched,
                  context: context)
    }
}
