//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Equatable, Codable {
    var title: String
    
    /*
     identifier and hasWatched are not a part of The Movie DB API, however they will be used both on Firebase and on the application itself.
     In order make the MovieRepresentation struct decode properly when fetching from the API, their types should stay optional.
     */
    
    var identifier: UUID
    var hasWatched: Bool?
}

/*
 Represents the full JSON returned from searching for a movie.
 The actual movies are in the "results" dictionary of the JSON.
 */
struct MovieRepresentations: Codable {
    let results: [MovieRepresentation]
}
