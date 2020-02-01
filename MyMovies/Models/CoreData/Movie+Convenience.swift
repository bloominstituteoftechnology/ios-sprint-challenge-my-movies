//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Kenny on 1/31/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else {return nil}
        return MovieRepresentation(title: title, identifier: identifier ?? UUID(), hasWatched: hasWatched)
    }
    
    
    @discardableResult convenience init(title: String, identifier: UUID, hasWatched: Bool, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(title: movieRepresentation.title, identifier: movieRepresentation.identifier ?? UUID(), hasWatched: movieRepresentation.hasWatched ?? false)
    }
    
}
