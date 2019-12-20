//
//  MovieSearchCellDelegate.swift
//  MyMovies
//
//  Created by Chad Rutherford on 12/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

protocol MovieSearchCellDelegate: class {
    func didAdd(_ movie: Movie)
}
