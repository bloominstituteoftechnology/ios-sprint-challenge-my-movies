//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Hannah Bain on 8/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct MovieSearch: Decodable {
    let results: [MovieRepresentation]
}

struct MovieRepresentation: Decodable {
    let hasWatched: Bool
    let identifier: UUID
    let title: String 
}


