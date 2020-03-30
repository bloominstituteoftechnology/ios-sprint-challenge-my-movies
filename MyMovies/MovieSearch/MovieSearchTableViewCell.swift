//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Shawn Gee on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var movieRepresentation: MovieRepresentation? { didSet { updateTitleLabel() }}
    var movieController: MovieController?
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!

    
    // MARK: - IBActions
    
    @IBAction func addMovieTapped(_ sender: UIButton) {
        guard let representation = movieRepresentation else { return }
        
        movieController?.addMovie(with: representation)
    }
    
    
    // MARK: - Private
    
    private func updateTitleLabel() {
        titleLabel.text = movieRepresentation?.title
    }

}
