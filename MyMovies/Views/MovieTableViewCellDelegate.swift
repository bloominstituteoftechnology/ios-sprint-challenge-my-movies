//
//  MovieTableViewCellDelegate.swift
//  MyMovies
//
//  Created by patelpra on 5/2/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

protocol MovieTableViewCellDelegate: class {
    func toggleHasBeenSeen(for cell: MyMoviesTableViewCell)
}
