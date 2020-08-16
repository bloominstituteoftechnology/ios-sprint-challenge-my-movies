//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by ronald huston jr on 8/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        
        return MovieRepresentation(title: title, identifier: identifier?.uuidString ?? "", hasWatched: hasWatched)
    }
    
    //  to conveniently initialize a movie object
    @discardableResult convenience init?(title: String,
                                         identifier: UUID = UUID(),
                                         hasWatched: Bool,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifier = UUID(uuidString: movieRepresentation.identifier ?? "") else { return nil }
        
        self.init(title: movieRepresentation.title,
                  identifier: identifier,
                  hasWatched: movieRepresentation.hasWatched,
                  context: context)
    }
}
