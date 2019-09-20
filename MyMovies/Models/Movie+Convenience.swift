//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Alex Shillingford on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title,
            let identifier = identifier else { return nil }
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
}
