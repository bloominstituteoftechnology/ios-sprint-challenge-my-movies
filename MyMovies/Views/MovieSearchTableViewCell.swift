//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by BDawg on 11/17/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MovieSearchTableViewCell: UITableViewCell {
    
    let myMoviesController = MyMoviesController()
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
        
    }
    
    @IBAction func addMovieTapped(_ sender: Any) {
        
        guard let title = movieTitleLabel.text else { return }
        
        myMoviesController.createMyMovie(title: title)
        
        
    }
    
}
