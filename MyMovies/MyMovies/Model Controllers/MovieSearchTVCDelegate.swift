//
//  MovieSearchTVCDelegate.swift
//  MyMovies
//
//  Created by Seschwan on 7/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

protocol MovieSearchTVCDelegate: class {
    func saveMoviesToList(cell: MovieSearchTableViewCell)
}
