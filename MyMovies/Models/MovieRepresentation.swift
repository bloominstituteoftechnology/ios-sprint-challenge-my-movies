//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Craig Belinfante on 8/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Codable {
    var identifier: String
    var title: String
    var hasWatched: Bool
}
