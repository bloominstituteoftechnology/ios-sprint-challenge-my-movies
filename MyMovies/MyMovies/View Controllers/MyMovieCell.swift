//
//  MyMovieCell.swift
//  MyMovies
//
//  Created by Jerrick Warren on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class MyMovieCell: UITableViewCell {
    
    private func updateViews(){
        guard let movie = movie else {return}
        movieLabel.text = movie.title
        
        //toogle button
        
        if movie.hasWatched {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
    }

    
    
    @IBAction func toggleHasWatchedButton(_ sender: Any) {
        guard let movie = movie else {return}
        let newState = !movie.hasWatched
        movieController?.updateMovie(movie: movie, hasWatched: newState)
        
    }
    
    var movie: Movie?{
        didSet {
            updateViews()
        }
    }
    
    // outlets
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    var movieController: MovieController?
}
