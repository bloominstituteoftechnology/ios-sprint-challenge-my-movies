//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Eoin Lavery on 14/10/2019.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard !movieRepresentation.title.isEmpty, let identifier = movieRepresentation.identifier, let hasWatched = movieRepresentation.hasWatched else { return nil }
        self.init(title: movieRepresentation.title, identifier: identifier, hasWatched: hasWatched)
    }
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title, let identifier = identifier, !title.isEmpty else { return nil }
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
}
