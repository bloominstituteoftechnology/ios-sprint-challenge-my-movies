//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Cora Jacobson on 8/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Codable {
    var identifier: String
    var title: String
    var hasWatched: Bool
}
