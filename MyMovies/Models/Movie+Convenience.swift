//
//  Movie.swift
//  Movie List
//
//  Created by Jordan Christensen on 8/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    var entryRepresentation: MovieRepresentation? {
        guard let title = title, let identifier = identifier else {return nil}
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    @discardableResult convenience init(title: String, hasWatched: Bool, identifier: UUID, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
    }
    
    @discardableResult convenience init?(movieRep: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let hasWatched = movieRep.hasWatched, let identifier = movieRep.identifier else { return nil }
        self.init(title: movieRep.title, hasWatched: hasWatched, identifier: identifier, context: context)
    }
}
