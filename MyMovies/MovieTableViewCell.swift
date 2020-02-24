//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Joshua Rutkowski on 2/23/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    // MARK: - IBAOutlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    var myMoviesController: MyMoviesController?
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        movieTitleLabel.text = movie?.title
    }
    
    // MARK: - IBActions
    
    
    @IBAction func saveMovieTapped(_ sender: Any) {
        guard let movie = movie else { return }
        
        let newMovie = Movie(title: movie.title)
        myMoviesController?.sendMyMovieToServer(movie: newMovie)
    }
    
    
    
}
