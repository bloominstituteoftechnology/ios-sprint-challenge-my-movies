//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Zachary Thacker on 8/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation



struct MovieRepresentation: Decodable {
    let identifier: UUID
    let title: String
    let hasWatched: Bool
}
