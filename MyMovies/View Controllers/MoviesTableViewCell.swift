//
//  MoviesTableViewCell.swift
//  MyMovies
//
//  Created by denis cedeno on 12/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitleLabel: UILabel!
    
    @IBOutlet weak var hasWatchedButton: UIButton!
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    private func updateViews() {
        guard let movie = movie else { return }
        
        movieTitleLabel.text = movie.title
        let hasWatchedButtonTitle = movie.hasWatched ? "Watched" : "Unwatched"
        hasWatchedButton.setTitle(hasWatchedButtonTitle, for: .normal)
    }

}
