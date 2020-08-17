//
//  Movie+CoreDataProperties.swift
//  MyMovies
//
//  Created by Zachary Thacker on 8/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var hasWatched: Bool
    @NSManaged public var identifier: UUID
    @NSManaged public var title: String

}
