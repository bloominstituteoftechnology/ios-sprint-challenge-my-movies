//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Chris Gonzales on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    convenience init(hasWatched: Bool = false,
                                        identifier: UUID,
                                        title: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {

        self.init(context: context)
        
        self.hasWatched = hasWatched
        self.identifier = UUID()
        self.title = title
    }
    
    convenience init?(movieRepresentation: MovieRepresentation,
                                         context: NSManagedObjectContext) {
         let hasWatched = movieRepresentation.hasWatched ?? false
            let identifier = movieRepresentation.identifier ?? UUID()
        
        self.init(hasWatched: hasWatched,
        identifier: identifier,
        title: movieRepresentation.title)
    }
    
    var entryRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
}

