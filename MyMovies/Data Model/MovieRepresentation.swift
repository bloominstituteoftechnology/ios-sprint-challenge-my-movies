//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Josh Kocsis on 6/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Codable {
    var identifier: String
    var title: String
    var hasWatched: Bool
}
