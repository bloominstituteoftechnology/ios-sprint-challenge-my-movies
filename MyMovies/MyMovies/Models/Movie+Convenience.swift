//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Farhan on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {

    convenience init(title: String, hasWatched: Bool, identifier: UUID = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext){

        self.init(context: context)
        
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
        

    }
    
    convenience init?(movieRep: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        
        guard let hasWatched = movieRep.hasWatched, let identifier = movieRep.identifier else {
            return nil
        }
        
        self.init(title: movieRep.title, hasWatched: hasWatched, identifier: identifier, context: context)
        
    }

}
