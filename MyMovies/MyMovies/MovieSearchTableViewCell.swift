//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Nathanael Youngren on 2/22/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        guard let movieRepresentation = movieRepresentation else { return }
        movieController?.addMovie(title: movieRepresentation.title)
    }
    
    private func updateViews() {
        guard let movieRepresentation = movieRepresentation else { return }
        titleLabel.text = movieRepresentation.title
    }

    @IBOutlet weak var titleLabel: UILabel!
    
    var movieController: MovieController?
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
}
