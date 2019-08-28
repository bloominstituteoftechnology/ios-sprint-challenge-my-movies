//
//  SearchMovieTableViewCellDelegate.swift
//  MyMovies
//
//  Created by Nathan Hedgeman on 8/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

protocol SearchMovieTableViewCellDelegate: class {
    func addMovieToCoreData(for cell: SearchMovieTableViewCell)
}
