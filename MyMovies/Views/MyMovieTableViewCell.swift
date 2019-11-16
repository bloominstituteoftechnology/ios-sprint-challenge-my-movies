//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Niranjan Kumar on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    var movieController: MovieController?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }

    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    
    
    @IBAction func hasWatchedTapped(_ sender: Any) {
        movie?.hasWatched.toggle()
        
        if let movie = movie {
            movieController?.put(movie: movie)
            
            if movie.hasWatched {
                hasWatchedButton.setTitle("Need to Watch", for: .normal)
            } else {
                hasWatchedButton.setTitle("Watched", for: .normal)
            }
            
        }
        
        updateViews()
        
    }
    
    
    private func updateViews(){
        movieTitle?.text = movie?.title
        guard let watched = movie?.hasWatched else { return }
        
        if watched {
            hasWatchedButton.setTitle("Need to Watch", for: .normal)
        } else {
            hasWatchedButton.setTitle("Watched", for: .normal)
        }
        
    }
    

}
