//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by ronald huston jr on 8/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Equatable, Codable {
    let title: String
    let identifier: String
    let hasWatched: Bool
}

struct MovieRepresentations: Codable {
    let results: [MovieRepresentation]
}
