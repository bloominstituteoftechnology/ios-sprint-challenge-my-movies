//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Kevin Stewart on 2/21/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        return MovieRepresentation(title: title!, identifier: identifier, hasWatched: hasWatched)
    }
    @discardableResult
    convenience init(title: String,
                     identifier: UUID = UUID(),
                     hasWatched: Bool,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
}
