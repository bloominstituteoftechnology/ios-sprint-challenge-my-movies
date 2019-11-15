//
//  Movie+convenience.swift
//  MyMovies
//
//  Created by brian vilchez on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    //MARK: - properties
    
    private var movieRep: MovieRepresentation {
        return MovieRepresentation(title:title!, identifier: identifier, hasWatched: hasBeenWatched)
    }
    
    //MARK: - initializers
    convenience init(title: String, hasBeenWatched: Bool = false , identifier: UUID = UUID(), context: NSManagedObjectContext) {
        self.init(context:context)
        
        self.title = title
        self.hasBeenWatched = hasBeenWatched
        self.identifier = identifier
    }
    
    @discardableResult convenience init?(movieRep: MovieRepresentation, context: NSManagedObjectContext) {
        guard let identifier = movieRep.identifier,
            let hasBeenWatched = movieRep.hasWatched else { return nil }
        
        self.init(title: movieRep.title, hasBeenWatched: hasBeenWatched, identifier: identifier, context: context)
    }
    
    
}
