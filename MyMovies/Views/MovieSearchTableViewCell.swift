//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Joe Thunder on 12/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    let movieController = MovieController()
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        
    }
    
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        guard let title = titleLabel.text else { return }
        movieController.create(title: title)
        movieController.fetchMovies()
        
    }
    
    
}
