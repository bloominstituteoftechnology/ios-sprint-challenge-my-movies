//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Daniela Parra on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell, MovieControllerProtocol {

    private func updateViews() {
        guard let movie = movie else { return }
        
        movieLabel.text = movie.title
        if movie.hasWatched {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
    }

    
    @IBAction func changeHasWatched(_ sender: Any) {
        
        guard let movie = movie else { return }
        
        let newStatus = !movie.hasWatched
        
        movieController?.updateMovie(movie: movie, hasWatched: newStatus)
        
    }
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    var movieController: MovieController?

    @IBOutlet weak var hasWatchedButton: UIButton!
    @IBOutlet weak var movieLabel: UILabel!
    
}
