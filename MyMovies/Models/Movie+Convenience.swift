//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Shawn James on 5/2/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        guard let id = identifier,
            let title = title else { return nil }
        
        return MovieRepresentation(title: title,
                                   identifier: id,
                                   hasWatched: hasWatched)
    }
    
    @discardableResult convenience init(title: String,
                                        identifier: UUID = UUID(),
                                        hasWatched: Bool = false,
                                        context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    // converts JSON to CoreData
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation,
                                         context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        
        self.init(title: movieRepresentation.title,
                  identifier: movieRepresentation.identifier!,
                  hasWatched: movieRepresentation.hasWatched ?? false)
    }
    
}
