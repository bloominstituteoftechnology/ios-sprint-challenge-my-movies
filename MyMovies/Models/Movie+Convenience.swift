//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Tobi Kuyoro on 28/02/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title,
            let identifier = identifier else { return nil }
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    convenience init(title: String,
                     hasWatched: Bool = false,
                     identifier: UUID = UUID(),
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let hasWatched = movieRepresentation.hasWatched,
            let identifier = movieRepresentation.identifier else { return nil }
        
        self.init(title: movieRepresentation.title,
                  hasWatched: hasWatched,
                  identifier: identifier,
                  context: context)
    }
}
