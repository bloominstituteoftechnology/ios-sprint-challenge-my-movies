//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Elizabeth Thomas on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    @discardableResult convenience init(title: String,
                                        identifier: UUID? = UUID(),
                                        hasWatched: Bool? = false) {
        
        self.init(context: CoreDataStack.shared.mainContext)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched ?? false
        
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {

        self.init(title: movieRepresentation.title,
                   identifier: movieRepresentation.identifier,
                   hasWatched: movieRepresentation.hasWatched)
        
    }
    
    var movieRepresentation: MovieRepresentation? {
        
        guard let title = title else { return nil }
        
        let watched = hasWatched ?? false
        let id = identifier ?? UUID()
        
        return MovieRepresentation(title: title,
                                   identifier: id,
                                   hasWatched: watched)
        
    }
    
    
}
