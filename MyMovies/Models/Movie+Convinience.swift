//
//  Movie+Convinience.swift
//  MyMovies
//
//  Created by Zachary Thacker on 8/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    //Regular convinience init
    @discardableResult
    convenience init(identifier: UUID,
                     title: String,
                     hasWatched: Bool,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
    }
    //Representation convinience init
    @discardableResult
    convenience init(representation: MovieRepresentation) {
        self.init(identifier: representation.identifier,
                      title: representation.title,
                      hasWatched: representation.hasWatched)
        }
    
    //Computed variable ->representation
    var representation: MovieRepresentation? {
        return MovieRepresentation(identifier: identifier,
                                   title: title,
                                   hasWatched: hasWatched)

    }
}
