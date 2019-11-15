//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Dennis Rudolph on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    var movieRep: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
     // MARK: - Methods
    
    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        guard let movieRep = movieRep else { return }
        
        MovieController.shared.createMovieFromRep(movieRepresentation: movieRep)
    }
    
    func updateViews() {
        guard let movieRep = movieRep else { return }
        movieTitleLabel.text = movieRep.title
    }
}
