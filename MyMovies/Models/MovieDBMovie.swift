//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 BloomTech. All rights reserved.
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
