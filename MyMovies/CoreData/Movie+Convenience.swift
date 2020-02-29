//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Nick Nguyen on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

 extension Movie {
    
    var movieRepresentation : MovieRepresentation? {
     
        return MovieRepresentation(title: title ?? "", identifier: identifier, hasWatched: hasWatched)
    }
    
    convenience init(title: String,identifier:UUID = UUID(),hasWatched:Bool,context: NSManagedObjectContext) {
        self.init(context:context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
  
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext ) {
        
        guard let hasWatched = movieRepresentation.hasWatched else { return nil }
        
        self.init(title:movieRepresentation.title,identifier: movieRepresentation.identifier ?? UUID(),hasWatched: hasWatched,context:context)
      
    
}
}
