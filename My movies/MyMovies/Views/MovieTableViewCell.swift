//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Angelique Abacajan on 2/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: - Properties
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }

    // MARK: - Methods
    private func updateViews() {
        guard let movie = movieRepresentation else { return }
        titleLabel.text = movie.title
    }

}


