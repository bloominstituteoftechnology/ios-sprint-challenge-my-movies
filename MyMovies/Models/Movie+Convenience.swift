//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Kenneth Jones on 6/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    var movieRep: MovieRepresentation? {
        guard let title = title else { return nil }
        
        return MovieRepresentation(identifier: identifier?.uuidString ?? "", title: title, hasWatched: hasWatched)
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
    
    @discardableResult convenience init?(movieRep: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifier = UUID(uuidString: movieRep.identifier) else {
                return nil }
        
        self.init(identifier: identifier,
                  title: movieRep.title,
                  hasWatched: movieRep.hasWatched,
                  context: context)
    }
}
