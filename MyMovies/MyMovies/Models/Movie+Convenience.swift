//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Andrew Dhan on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    @discardableResult convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context:NSManagedObjectContext = CoreDataStack.shared.mainContext){
        
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    static func save(){
        let moc = CoreDataStack.shared.mainContext
        do {
            try moc.save()
        } catch {
            NSLog("Error saving: \(error)")
            moc.reset()
            return
        }
    }
}
