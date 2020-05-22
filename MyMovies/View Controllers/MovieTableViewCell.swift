//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Vincent Hoang on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class MovieTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var watchedButton: UIButton!
    
    var movieController: MovieController?
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        if let movie = movie {
            titleLabel.text = movie.title
            
            updateWatchedStatus(watched: movie.hasWatched)
        }
    }
    
    private func updateWatchedStatus(watched: Bool) {
        if watched {
            watchedButton.setImage(UIImage(systemName: "film.fill"), for: .normal)
            } else {
            watchedButton.setImage(UIImage(systemName: "film"), for: .normal)
        }
    }
    
    @IBAction func watchedButtonPressed(_ sender: UIButton) {
        if let movie = movie {
            movieController?.toggleHasWatched(movie)
        }
    }
}
