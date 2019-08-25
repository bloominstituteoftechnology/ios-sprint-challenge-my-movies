//
//  MovieTableViewCellDelegate.swift
//  MyMovies
//
//  Created by Nathan Hedgeman on 8/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

protocol MovieTableViewCellDelegate: class {
    func toggleHasBeenSeen(for cell: MyMoviesTableViewCell)
}
