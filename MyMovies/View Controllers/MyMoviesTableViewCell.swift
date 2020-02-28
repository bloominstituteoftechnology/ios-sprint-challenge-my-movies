//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Elizabeth Wingate on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedOutlet: UIButton!
    
    var shouldChange: Bool = false
    
    @IBAction func hasWatchedAction(_ sender: Any) {
        
        guard let movie = movie else { return }
        
        switch movie.hasWatched {
        case true:
            movie.hasWatched = false
            hasWatchedOutlet.setTitle("Unwatched", for: .normal)
            MovieDataController.shared.updateMovie(movie: movie, hasWatched: false)
        case false:
            movie.hasWatched = true
            hasWatchedOutlet.setTitle("Watched", for: .normal)
            MovieDataController.shared.updateMovie(movie: movie, hasWatched: true)
        }
        
    }
    
    static let reuseIdentifier = "MyMovieCell"
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        movieTitleLabel.text = movie?.title
                
        if movie?.hasWatched == false {
            hasWatchedOutlet.setTitle("Unwatched", for: .normal)
        } else {
            hasWatchedOutlet.setTitle("Watched", for: .normal)
        }
    }
}
