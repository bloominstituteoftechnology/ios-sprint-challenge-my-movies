//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Jonalynn Masters on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {

    @discardableResult convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }

    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let hasWatched = movieRepresentation.hasWatched ?? false
        let identifier = movieRepresentation.identifier ?? UUID()

        self.init(title: movieRepresentation.title, identifier: identifier, hasWatched: hasWatched, context: context)
    }

    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
}
