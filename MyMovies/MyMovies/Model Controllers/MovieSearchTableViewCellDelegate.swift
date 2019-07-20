//
//  MovieSearchTableViewCellDelegate.swift
//  MyMovies
//
//  Created by Michael Stoffer on 7/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

protocol MovieSearchTableViewCellDelegate: class {
    func saveMovieToMyMovies(for cell: MovieSearchTableViewCell)
}
