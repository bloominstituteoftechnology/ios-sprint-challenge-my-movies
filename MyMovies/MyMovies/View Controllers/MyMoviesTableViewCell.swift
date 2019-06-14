//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Thomas Cacciatore on 6/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    private func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        if movie.hasWatched {
            hasWatchedButton.setTitle("Watched", for: .normal
            )
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
    }

    
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
}
