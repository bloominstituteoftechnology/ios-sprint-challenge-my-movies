//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Harmony Radley on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
     static let reuseIdentifier = "MovieCell"

   // MARK: - Properties
    var movieController: MovieController?
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let movieTitle = movieTitleLabel.text,
            !movieTitle.isEmpty else { return }
    }
    
    func updateViews() {
        movieTitleLabel.text = movie?.title
    }
    
    
}
