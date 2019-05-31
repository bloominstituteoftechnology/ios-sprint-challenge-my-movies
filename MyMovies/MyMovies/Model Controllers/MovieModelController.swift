//
//  MovieModelController.swift
//  MyMovies
//
//  Created by Christopher Aronson on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String {
    case PUT
    case GET
    case POST
    case DELETE
}

class MovieModelController {

    func save(contetex: NSManagedObjectContext) {

        do {
            try contetex.save()
        } catch  {
            NSLog("Could Not save data to persistent Stores: \(error)")
        }
    }

    func create(title: String) {

        _ = Movie(title: title)
    }

    func update(movie: Movie, hasWatch: Bool) {
        movie.hasWatched = hasWatch
    }

    func delete(movie: Movie, context: NSManagedObjectContext) {

        context.delete(movie)
    }
}
