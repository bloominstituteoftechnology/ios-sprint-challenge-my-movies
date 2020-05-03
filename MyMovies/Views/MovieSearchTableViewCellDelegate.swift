//
//  MovieSearchTableViewCellDelegate.swift
//  MyMovies
//
//  Created by patelpra on 5/2/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

protocol MovieSearchTableViewCellDelegate: class {
    func saveMovieToMyMovies(for cell: MovieSearchTableViewCell)
}
