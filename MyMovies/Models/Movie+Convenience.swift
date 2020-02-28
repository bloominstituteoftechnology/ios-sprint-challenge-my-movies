//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Chris Gonzales on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    @discardableResult convenience init(hasWatched: Bool = false,
                                        identifier: UUID,
                                        title: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        //        guard let hasWatched = hasWatched else { return }
        
        self.init(context: context)
        
        self.hasWatched = hasWatched
        self.identifier = UUID()
        self.title = title
        
        
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation,
                                         context: NSManagedObjectContext) {
        guard let hasWatched = movieRepresentation.hasWatched,
            let identifier = movieRepresentation.identifier else { return }
        
        self.init(hasWatched: hasWatched,
                  identifier: identifier,
                  title: title!)
    }
    
    var entryRepresentation: MovieRepresentation {
        return MovieRepresentation(title: title!,
                                   identifier: identifier,
                                   hasWatched: hasWatched)
    }
}

