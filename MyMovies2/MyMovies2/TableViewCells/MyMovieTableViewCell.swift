//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Ryan Murphy on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    //var movieDataController: MovieDataController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    

    @IBOutlet weak var hasWatchedOutlet: UIButton!
    

    @IBAction func hasWatchedPressed(_ sender: Any) {
        guard let movie = movie else { return }
        
        switch movie.hasWatched {
        case true:
            movie.hasWatched = false
            hasWatchedOutlet.setTitle("Unwatched", for: .normal)
            MyMovieController.shared.updateMovie(movie: movie, hasWatched: false)
        case false:
            movie.hasWatched = true
            hasWatchedOutlet.setTitle("Watched", for: .normal)
            MyMovieController.shared.updateMovie(movie: movie, hasWatched: true)
        }
    }
    
 
    
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
