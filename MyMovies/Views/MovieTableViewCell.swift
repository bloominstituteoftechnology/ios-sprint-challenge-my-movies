//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_204 on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    // MARK: - Properties
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Private Methods
    
    private func updateViews() {
        guard let movie = movieRepresentation else { return }
        titleLabel.text = movie.title
    }
}
