//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Bronson Mullens on 6/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct MovieDBMovie: Codable {
    let title: String
}

/*
 Represents the full JSON returned from searching for a movie.
 The actual movies are in the "results" dictionary of the JSON.
 */
struct MovieDBResults: Codable {
    let results: [MovieDBMovie]
}
