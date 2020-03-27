//
//  MovieController.swift
//  MyMovies
//
//  Created by Shawn Gee on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MovieController {
    static let shared = MovieController()
    private init() {}
    
    func addMovie(with representation: MovieRepresentation) {
        // Could add functionality to avoid duplication
        Movie(representation)
        try? CoreDataStack.shared.save()
    }
}

