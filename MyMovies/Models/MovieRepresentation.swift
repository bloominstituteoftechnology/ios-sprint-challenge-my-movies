//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Eoin Lavery on 17/08/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

struct MovieRepresentation: Codable, Equatable {
    let identifier: UUID?
    let title: String?
    let hasWatched: Bool?
}
