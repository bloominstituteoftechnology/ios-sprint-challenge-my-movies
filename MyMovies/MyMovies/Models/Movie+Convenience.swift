//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Alex on 5/31/19.
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
    
    // Used for converting a MovieRepresentation from Firebase to a Movie object
    
    convenience init(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let title = movieRepresentation.title
        let identifier = movieRepresentation.identifier ?? UUID()
        let hasWatched = movieRepresentation.hasWatched ?? false
        self.init(title: title, identifier: identifier, hasWatched: hasWatched, context: context)
    }
}
