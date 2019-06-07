//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Mitchell Budge on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    func updateViews() {
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
        if movie.hasWatched == true {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
    }
    
    @IBAction func hasWatchedButtonPressed(_ sender: Any) {
        guard let movie = movie else { return }
        movie.hasWatched = !movie.hasWatched
        movieController?.put(movie: movie)
    }
    
    // MARK: - Properties & Outlets
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    var movieController: MovieController?
    var movieRep: MovieRepresentation?
}


