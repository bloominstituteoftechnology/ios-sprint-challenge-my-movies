//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by BDawg on 11/17/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    var myMoviesController: MyMoviesController?
    
    @IBOutlet weak var myMovieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        
        myMovieTitleLabel.text = movie?.title
        
        if movie?.hasWatched == true {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Not Watched", for: .normal)
        }
    }
    
    @IBAction func hasWatchTapped(_ sender: Any) {
        
        guard let movie = movie else { return }
        
        movie.hasWatched.toggle()
        if movie.hasWatched == true {
            hasWatchedButton.setTitle("Watched", for: .normal)
            movie.hasWatched = true
            myMoviesController?.sendMovieToServer(movie: movie)
            
        } else if movie.hasWatched == false {
            hasWatchedButton.setTitle("Not Watched", for: .normal)
            movie.hasWatched = false
            myMoviesController?.sendMovieToServer(movie: movie)
        }
        
    }
    
}
