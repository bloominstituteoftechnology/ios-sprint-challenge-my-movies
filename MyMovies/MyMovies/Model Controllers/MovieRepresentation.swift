//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Jocelyn Stuart on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Decodable, Equatable {
    
    let title: String
    let identifier: String
    let hasWatched: Bool
    
}

func ==(lhs: MovieRepresentation, rhs: Movie) -> Bool {
    return rhs.identifier == lhs.identifier &&
        rhs.title == lhs.title &&
        rhs.hasWatched == lhs.hasWatched
}

func ==(lhs: Movie, rhs: MovieRepresentation) -> Bool {
    return rhs == lhs
}

func !=(lhs: MovieRepresentation, rhs: Movie) -> Bool {
    return !(lhs == rhs)
}

func !=(lhs: Movie, rhs: MovieRepresentation) -> Bool {
    return rhs != lhs
}

