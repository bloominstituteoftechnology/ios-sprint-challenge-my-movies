//
//  Movie.swift
//  MyMovies
//
//  Created by Bree Jeune on 6/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(_ title:String, _ hasWatched:Bool=false, _ identifier:UUID?=nil, moc:NSManagedObjectContext)
    {
        self.init(context:moc)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier ?? UUID()
    }

    func getStub() -> MovieRepresentation
    {
        return MovieRepresentation(title:title!, identifier:identifier!, hasWatched:hasWatched)
    }

    func apply(_ representation:MovieRepresentation)
    {
        self.title = representation.title
        if let id = representation.identifier {
            self.identifier = id
        }

        if let hasWatched = representation.hasWatched {
            self.hasWatched = hasWatched
        }

    }


}
