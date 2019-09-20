//
//  Movie+CoreDataProperties.swift
//  MyMovies
//
//  Created by brian vilchez on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        let fetchRequest = NSFetchRequest<Movie>(entityName: "Movie")
        return fetchRequest
    }

    @NSManaged public var title: String?
    @NSManaged public var identifier: UUID?
    @NSManaged public var hasWatched: Bool

}
