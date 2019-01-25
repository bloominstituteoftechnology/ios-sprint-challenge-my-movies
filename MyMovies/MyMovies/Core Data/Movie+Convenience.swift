//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Ivan Caldwell on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let title = movieRepresentation.title
        let identifier = movieRepresentation.identifier
        let hasWatched = movieRepresentation.hasWatched
        self.init(title: title, identifier: identifier ?? UUID(), hasWatched: hasWatched ?? false, context: context)
//        Initializer for conditional binding must have Optional type, not 'String'
//        self.init()
//        title = movieRepresentation.title
//        identifier = movieRepresentation.identifier
//        hasWatched = movieRepresentation.hasWatched!
        // I can force I uwrapp because I provide hasWatched with a default...
    }
}
