//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Jessie Ann Griffin on 12/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedText: UIButton!
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        
        movieTitleLabel.text = movie.title
        if movie.hasWatched {
            hasWatchedText.titleLabel?.text = "Watched"
        } else {
            hasWatchedText.titleLabel?.text = "To Watch"
        }
    }
    
    @IBAction func hasWatched(_ sender: UIButton) {
        guard let movie = movie else { return }

        movie.hasWatched = !movie.hasWatched
    }
}
