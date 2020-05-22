//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Joe Joe on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Codable {
    let title: String
    var identifier: String
    var hasWatched: Bool
}


