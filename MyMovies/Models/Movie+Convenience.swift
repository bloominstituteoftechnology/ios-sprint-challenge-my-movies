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
    var movieRepresentations: MovieRepresentation? {
        guard let title = title else { return nil }

        return MovieRepresentation(hasWatched: hasWatched,
                                   identifier: identifier?.uuidString ?? "",
                                   title: title)
    }

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

    @discardableResult convenience init?(movieRespresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifier = UUID(uuidString: movieRespresentation.identifier!) else { return nil }

        self.init(identifier: identifier,
                  title: movieRespresentation.title,
                  hasWatched: movieRespresentation.hasWatched,
                  context: context)
    }

}
