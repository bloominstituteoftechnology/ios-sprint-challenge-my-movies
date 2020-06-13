//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Josh Kocsis on 6/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {

    var movieRepresentation: MovieRepresentation? {
        guard let title = title,
            let identifier = identifier else { return nil }

        return MovieRepresentation(identifier: identifier.uuidString, title: title, hasWatched: hasWatched)
    }

    @discardableResult convenience init(identifier: UUID = UUID(),
                                        title: String,
                                        hasWatched: Bool = false,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
    }

    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {

        guard let identifier = UUID(uuidString: movieRepresentation.identifier) else { return nil }
        self.init(identifier: identifier,
                  title: movieRepresentation.title,
                  hasWatched: movieRepresentation.hasWatched,
                  context: context)
    }
}
