//
//  Movie.swift
//  MyMovies
//
//  Created by brian vilchez on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    convenience init(hasWatched: Bool = false , title:String, identifier: String = UUID().uuidString, context: NSManagedObjectContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }

    var movieRepresentation: MovieRepresentation {
        return
    }
}
