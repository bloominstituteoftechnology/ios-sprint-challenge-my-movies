//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Patrick Millet on 12/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
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
