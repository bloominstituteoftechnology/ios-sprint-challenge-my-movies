//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Lisa Sampson on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

// MARK: - Protocols
protocol MovieSearchTableViewCellDelegate: class {
    func addMovieButtonTapped(on cell: MovieSearchTableViewCell)
}

class MovieSearchTableViewCell: UITableViewCell {

    // MARK: - Properties and Outlets
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: MovieSearchTableViewCellDelegate?
    var movieRep: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - View Loading
    func updateViews() {
        guard let movie = movieRep else { return }
        titleLabel.text = movie.title
        titleLabel.textColor = .white
    }
    
    // MARK: - Actions
    @IBAction func addButtonTapped(_ sender: Any) {
        delegate?.addMovieButtonTapped(on: self)
    }
}
