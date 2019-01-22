//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Codable, Equatable {
    let title: String
    let identifier: UUID?
    let hasWatched: Bool?
}
/*
 Represents the full JSON returned from searching for a movie.
 The actual movies are in the "results" dictionary of the JSON.
 */
struct MovieRepresentations: Codable {
    let results: [MovieRepresentation]
}

func == (lhs: MovieRepresentation, rhs: Movie) -> Bool {
    return lhs.identifier == rhs.identifier && lhs.title == rhs.title && lhs.hasWatched == rhs.hasWatched
}

func == (lhs: Movie, rhs: MovieRepresentation) -> Bool {
    return rhs == lhs
}

func != (lhs: MovieRepresentation, rhs: Movie) -> Bool {
    return !(rhs == lhs)
}

func != (lhs: Movie, rhs: MovieRepresentation) -> Bool {
    return rhs != lhs
}

