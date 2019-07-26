//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Sean Acres on 7/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    var movie: Movie?
    var movieController: MovieController?
    
    @IBOutlet weak var titleLabel: UILabel!

    @IBAction func hasWatchedTapped(_ sender: Any) {
        
    }
}
