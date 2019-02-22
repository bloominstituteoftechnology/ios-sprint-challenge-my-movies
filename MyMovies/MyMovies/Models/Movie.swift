//
//  Movie.swift
//  MyMovies
//
//  Created by Cameron Dunn on 2/22/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie{
    @discardableResult convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        self.init(context: context)
        
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
}
