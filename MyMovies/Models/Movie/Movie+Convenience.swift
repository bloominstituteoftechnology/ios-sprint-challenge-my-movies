//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Shawn Gee on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    @discardableResult
    convenience init(title: String,
                     hasWatched: Bool = false,
                     identifier: UUID = UUID(),
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier.uuidString
    }
    
    @discardableResult
    convenience init?(_ movieRepresentation: MovieRepresentation,
                      context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let uuid: UUID
        
        if let idString = movieRepresentation.identifier,
            let id = UUID(uuidString: idString) {
            uuid = id
        } else {
            uuid = UUID()
        }
        
        self.init(title: movieRepresentation.title,
                  hasWatched: movieRepresentation.hasWatched ?? false,
                  identifier: uuid,
                  context: context)
    }
    
    var movieRepresentation: MovieRepresentation {
        MovieRepresentation(title: self.title, identifier: self.identifier, hasWatched: self.hasWatched)
    }
}
