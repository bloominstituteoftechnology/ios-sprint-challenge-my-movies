//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Ilgar Ilyasov on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData


extension Movie {
    
    @discardableResult convenience init(title: String,
                                        identifier: String,
                                        hasWatched: Bool = false,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    @discardableResult convenience init?(movie: Movie,
                                        movieRepresentation: MovieRepresentation,
                                        context: NSManagedObjectContext) {
        
        guard let id  = movieRepresentation.identifier,
            let hasWatched = movieRepresentation.hasWatched else {return nil}
        
        self.init(title: movieRepresentation.title,
                  identifier: id.uuidString,
                  hasWatched: hasWatched,
                  context: context)
        
    }
}
