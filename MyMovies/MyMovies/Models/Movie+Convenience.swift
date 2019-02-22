//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Nathanael Youngren on 2/22/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import CoreData

extension Movie {
    
    convenience init(title: String, identifier: UUID, hasWatched: Bool, context: NSManagedObjectContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
}
