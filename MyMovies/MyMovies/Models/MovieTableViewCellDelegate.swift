//
//  MovieTableViewCellDelegate.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_34 on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MovieTableViewCellDelegate: class {
    func toggleHasWatched(for cell: MyMoviesTableViewCell)
}
