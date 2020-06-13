//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//
// ChrisPrice

import Foundation

struct MovieRepresentation: Equatable, Codable {
    var title: String
    var identifier: UUID?
    var hasWatched: Bool?
}

struct MovieRepresentations: Codable {
    let results: [MovieRepresentation]
}

/*
 identifier and hasWatched are not a part of The Movie DB API, however they will be used both on Firebase and on the application itself.
 In order make the MovieRepresentation struct decode properly when fetching from the API, their types should stay optional.
 */

/*
"MovieRepresentations" represents the full JSON returned from searching for a movie.
The actual movies are in the "results" dictionary of the JSON.
*/
