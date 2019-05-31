//
//  MyMovies+Convenience.swift
//  MyMovies
//
//  Created by Christopher Aronson on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {

    var movieRepresentation: MovieRepresentation? {

        guard let title = title,
        let identifier = identifier
        else { return nil }

        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }

    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = true, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {

        self.init(context: context)

        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }

    convenience init?(movieRepresentation: MovieRepresentation) {

        self.init(title: movieRepresentation.title,
                   identifier: movieRepresentation.identifier ?? UUID(),
                   hasWatched: movieRepresentation.hasWatched ?? true)
    }
}
