//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Harmony Radley on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Codable {
    var identifier: String
    var title: String
    var hasWatched: Bool
}
