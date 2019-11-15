//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Jon Bash on 2019-11-15.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String, hasWatched: Bool, identifier: UUID, context: NSManagedObjectContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
}
