//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Craig Belinfante on 8/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum MovieWatched: String, CaseIterable {
    case unwatched
    case watched
}

extension Movie {
    
    //get representation from Movie
    var movieRep: MovieRepresentation? {
        guard let title = title else {return nil}
        
        return MovieRepresentation(identifier: identifier?.uuidString ?? "",
                                   title: title,
                                   hasWatched: hasWatched)
        
    }
    
    @discardableResult convenience init(identifier: UUID = UUID(),
                                        title: String,
                                        hasWatched: Bool = false,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext
    ) {
        self.init(context: context)
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
    }
    
    //MovieRep into Movie Object
    @discardableResult convenience init?(movieRep: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifer = UUID(uuidString: movieRep.identifier) else {return nil}
        
        self.init(identifier: identifer,
                  title: movieRep.title,
                  hasWatched: movieRep.hasWatched,
                  context: context)
    }
    
}

//Michael if you are reading this. I need to learn more about what this does.. had trouble coding it. Not sure I understand it.
