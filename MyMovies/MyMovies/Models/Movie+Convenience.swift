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
    
    // Give it an UUID identifier and false hasWatched value everytime a movie has been created
    
    @discardableResult convenience init(title: String,
                                        identifier: String = UUID().uuidString,
                                        hasWatched: Bool = false,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    // Initialize with MovieRepresentation
    
    @discardableResult convenience init?(movieRepresentation mr: MovieRepresentation,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        guard let id  = mr.identifier,
            let hasWatched = mr.hasWatched else {return nil}
        
        self.init(title: mr.title,
                  identifier: id.uuidString,
                  hasWatched: hasWatched,
                  context: context)
        
    }
}
