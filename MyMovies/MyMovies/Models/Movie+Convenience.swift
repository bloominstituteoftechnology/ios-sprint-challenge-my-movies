//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Lisa Sampson on 8/24/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String, hasWatched: Bool = false, identifier: UUID = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    convenience init(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let title = movieRepresentation.title
        let hasWatched = movieRepresentation.hasWatched ?? false
        let identifier = movieRepresentation.identifier ?? UUID()
        
        self.init(title: title, hasWatched: hasWatched, identifier: identifier, context: context)
    }
}
