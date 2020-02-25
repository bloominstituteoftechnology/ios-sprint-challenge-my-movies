//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Eoin Lavery on 25/02/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MovieWasAddedDelegate {
    func movieWasAdded(movie: MovieRepresentation)
}

class MovieSearchTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    //MARK: - Properties
    var delegate: MovieWasAddedDelegate?
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - Private Functions
    private func updateViews() {
        guard let movie = movieRepresentation else {
            return
        }
        
        movieTitleLabel.text = movie.title
    }
    
    //MARK: - IBActions
    @IBAction func addMovieTapped(_ sender: Any) {
        guard let movie = movieRepresentation else {
            return
        }
        
        delegate?.movieWasAdded(movie: movie)
    }
    
}
