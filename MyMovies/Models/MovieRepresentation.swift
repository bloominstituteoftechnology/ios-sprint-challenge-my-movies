//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by John McCants on 8/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Codable {
    let identifier: String
    let title: String
    let hasWatched: Bool
}
