//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Chris Price on 5/2/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    @discardableResult convenience init(hasWatched: Bool,
                                        identifier: UUID? = UUID(),
                                        title: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.hasWatched = hasWatched
        self.identifier = identifier
        self.title = title
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        guard let identifierString = movieRepresentation.identifier,
            let identifier = UUID(uuidString: identifierString) else { return nil }
        
        self.init(hasWatched: movieRepresentation.hasWatched ?? false,
                  identifier: identifier,
                  title: movieRepresentation.title,
                  context: context)
    }

    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        
        return MovieRepresentation(title: title,
                                   identifier: identifier?.uuidString ?? "",
                                   hasWatched: hasWatched)
    }
}
