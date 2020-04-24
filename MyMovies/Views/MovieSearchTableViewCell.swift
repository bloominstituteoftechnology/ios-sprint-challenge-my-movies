//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Chris Dobek on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MovieWasAddedDelegate {
    func movieWasAdded(movie: MovieRepresentation)
}

class MovieSearchTableViewCell: UITableViewCell {
    
    var delegate: MovieWasAddedDelegate?
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    
    
    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        guard let movie = movieRepresentation else {
                   return
               }

               delegate?.movieWasAdded(movie: movie)
           }
    
    // MARK: - Methods
    private func updateViews() {
        guard let movie = movieRepresentation else { return }
        titleLabel.text = movie.title
    }
    
}
