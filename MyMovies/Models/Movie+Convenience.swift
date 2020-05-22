//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Cody Morley on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    //MARK: - Properties -
    var representation: MovieRepresentation? {
        guard let identifier = identifier,
            let title = title else { return nil }
        
        return MovieRepresentation(identifier: identifier.uuidString,
                                   title: title,
                                   hasWatched: hasWatched)
    }
    
    
    
    //MARK: - Initializers -
    @discardableResult convenience init(identifier: UUID = UUID(),
                                        title: String,
                                        hasWatched: Bool = false,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
    }
    
    @discardableResult convenience init?(representation: MovieRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifier = UUID(uuidString: representation.identifier) else { return nil }
        
        self.init(identifier: identifier,
                  title: representation.title,
                  hasWatched: representation.hasWatched,
                  context: context)
    }
    
    
    
    
}
