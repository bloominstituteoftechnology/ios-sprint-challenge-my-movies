//
//  MyMovieCellDelegate.swift
//  MyMovies
//
//  Created by Chad Rutherford on 12/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MyMovieCellDelegate: class {
    func didWatchMovie(for cell: UITableViewCell)
}
