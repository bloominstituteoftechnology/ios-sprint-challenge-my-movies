 //
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Tobi Kuyoro on 03/02/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasBeenWatched: UIButton!
    
    var movieController: MovieController?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func hasBeenWatchedTapped(_ sender: Any) {
        guard let movie = movie else { return }
        
        movieController?.put(movie: movie)
        updateViews()
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        
        movieTitleLabel.text = movie.title
        
        movie.hasWatched.toggle()
        if movie.hasWatched  {
            hasBeenWatched.setTitle("Watched", for: .normal)
        } else {
            hasBeenWatched.setTitle("Unwatched", for: .normal)
        }
    }
}
