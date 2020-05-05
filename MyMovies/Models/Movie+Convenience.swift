//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Waseem Idelbi on 5/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title, let identifier = identifier else { return nil }
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }

   @discardableResult convenience init(title: String, hasWatched: Bool = false, identifier: UUID, context: NSManagedObjectContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    @discardableResult convenience init( _ movieRepresentation: MovieRepresentation, _ context: NSManagedObjectContext) {
        
        let rep = movieRepresentation
        self.init(title: rep.title, hasWatched: rep.hasWatched!, identifier: rep.identifier ?? UUID(), context: context)
        
    }
    
}
