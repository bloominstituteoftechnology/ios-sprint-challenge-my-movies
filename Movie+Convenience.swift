//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Austin Potts on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    //Initialize your Representation
    var movieRepresentation: MovieRepresentation? {
        guard let title = title,
            let identifier = identifier?.uuidString else{return nil}
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
        
    }
    
    
    convenience init(title: String, hasWatched: Bool?, identifier: UUID = UUID(), context: NSManagedObjectContext) {
        self.init(context:context)
        
        self.title = title
        self.hasWatched = true
        self.identifier = identifier
        
        
    }
    
    
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext) {
        guard let identifier = UUID(uuidString: movieRepresentation.identifier) else{return nil}
        
        self.init(title: movieRepresentation.title, hasWatched: true, identifier: identifier, context:context)
        
    }
    
    
    
}
