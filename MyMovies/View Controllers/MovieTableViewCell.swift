//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by brian vilchez on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var hasWatchedButton: UIButton!
    var movie: Movie?

    @IBAction func hasWatchedButton(_ sender: UIButton) {
    }
}
