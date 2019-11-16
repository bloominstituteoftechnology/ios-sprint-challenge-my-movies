//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Thomas Sabino-Benowitz on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    
    @discardableResult convenience init(title: String,
                                        identifier: UUID? = UUID(),
                                        hasWatched: Bool? = false,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = identifier
        self.hasWatched = hasWatched ?? false
        self.title = title
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {

        guard let identifier = movieRepresentation.identifier else {return nil}
//              let hasWatched = movieRepresentation.hasWatched else { return nil}
        
        self.init(title: movieRepresentation.title,
                  identifier: identifier,
                  hasWatched: movieRepresentation.hasWatched,
                  context: context)
    }
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else {return nil}
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
}
