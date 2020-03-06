//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Keri Levesque on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    //MARK: Outlets
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieButton: UIButton!
   
    //MARK: Properties
    static let reuseIdentifier = "MyMovieCell"
    var myMoviesController: MyMoviesController?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        movieTitleLabel.text = movie?.title
        if movie?.hasWatched == false {
            movieButton.setTitle("Unwatched", for: .normal)
        } else {
            movieButton.setTitle("Watched", for: .normal)
        }
    }
    
    //MARK: Actions
    
    
    @IBAction func movieWatchedTapped(_ sender: Any) {
       guard let movie = movie else { return }
            
            switch movie.hasWatched {
            case true:
                movie.hasWatched = false
                movieButton.setTitle("Unwatched", for: .normal)
                MyMoviesController.shared.updateMovie(movie: movie, hasWatched: false)
            case false:
                movie.hasWatched = true
                movieButton.setTitle("Watched", for: .normal)
                MyMoviesController.shared.updateMovie(movie: movie, hasWatched: true)
            }
    }
    
}
