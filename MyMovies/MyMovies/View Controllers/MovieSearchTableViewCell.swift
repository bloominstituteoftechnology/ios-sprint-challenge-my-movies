//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Mitchell Budge on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    func updateViews() {
        guard let movie = movieRep else { return }
        movieTitleLabel.text = movie.title
        movieTitleLabel.textColor = .white
        
    }

    
    @IBAction func addMovieButtonPressed(_ sender: Any) {
        print("Pressed!")
        guard let movie = movieRep else { return }
        movieController?.createMovie(title: movie.title, identifier: UUID())
        addMovieButton.setTitle("Added!", for: .normal)
    }
    
    // MARK: - Properties & Outlets
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    var movieController: MovieController?
    var movieRep: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
}
