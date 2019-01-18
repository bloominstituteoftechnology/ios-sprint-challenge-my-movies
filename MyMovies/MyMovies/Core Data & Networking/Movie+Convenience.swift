//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Austin Cole on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String, hasWatched: Bool = false, identifier: UUID, context: NSManagedObjectContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    convenience init?(movieRepresentation: MovieRepresentation) {
        self.init()
        self.title = movieRepresentation.title
        self.hasWatched = movieRepresentation.hasWatched!
        self.identifier = UUID(uuidString: movieRepresentation.identifier!)
    }
    
}
