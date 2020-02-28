//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by scott harris on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title, let id = identifier else { return nil }
        return MovieRepresentation(title: title, identifier: id, hasWatched: hasWatched)
    }
    
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        let id = movieRepresentation.identifier ?? UUID()
        let hasWatched = movieRepresentation.hasWatched ?? false
        self.title = movieRepresentation.title
        self.identifier = id
        self.hasWatched = hasWatched
    }
    
}
