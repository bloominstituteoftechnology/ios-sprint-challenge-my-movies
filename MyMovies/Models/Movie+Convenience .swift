//
//  Movie+Convenience .swift
//  MyMovies
//
//  Created by Tobi Kuyoro on 31/01/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    var movieRepresentation: MovieRepresentation? {
        guard let title = title,
        let identifier = identifier else { return nil }
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext) {
        guard let identifier = movieRepresentation.identifier,
            let hasWatched = movieRepresentation.hasWatched else { return nil }
        
        self.init(title: movieRepresentation.title,
                  identifier: identifier,
                  hasWatched: hasWatched,
                  context: context)
    }
}
