//
//  MovieSearchCell.swift
//  MyMovies
//
//  Created by Chad Rutherford on 12/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchCell: UITableViewCell {
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    // MARK: - Outlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
    }
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    // MARK: - Actions
    @IBAction func addMovieTapped(_ sender: UIButton) {
        /// Add Movie to Firebase
    }
}
