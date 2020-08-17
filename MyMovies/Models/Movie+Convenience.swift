//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Sammy Alvarado on 8/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
//    var movieRepresentations: MovieRepresentation? {
//
//    }

    @discardableResult convenience init(identifier: UUID = UUID(),
                                         title: String,
                                         hasWatched: Bool = false,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext
    ) {
        self.init(context: context)
        self.identifier = identifier
        self.hasWatched = hasWatched
        self.title = title

    }

}
