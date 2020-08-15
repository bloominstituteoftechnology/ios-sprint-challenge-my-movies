//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Gladymir Philippe on 8/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Codable {
    var identifier: UUID?
    var title: String
    var hasWatched: Bool?
}
