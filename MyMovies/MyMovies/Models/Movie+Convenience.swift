//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by De MicheliStefano on 17.08.18.
//  Copyright © 2018 Lambda School. All rights reserved.
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
    
    convenience init?(movieRep: MovieRepresentation, context: NSManagedObjectContext) {
        guard let hasWatched = movieRep.hasWatched, let identifier = movieRep.identifier else { return nil }
        
        self.init(title: movieRep.title,
                  hasWatched: hasWatched,
                  context: context)
        
        self.identifier = identifier
    }
    
}
