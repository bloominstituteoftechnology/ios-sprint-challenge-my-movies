//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Tobi Kuyoro on 28/02/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol AddMovieDelegate {
    func add(movieRepresentation: MovieRepresentation)
}

class MovieSearchTableViewCell: UITableViewCell {
    
    // MARK: - Outlets

    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var addToListButton: UIButton!
    
    // MARK: - Properties
    
    var delegate: AddMovieDelegate?
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func addToListTapped(_ sender: Any) {
        guard let movieRepresentation = movieRepresentation else { return }
        
        delegate?.add(movieRepresentation: movieRepresentation)

    }
    
    private func updateViews() {
        guard let movieRepresentation = movieRepresentation else { return }
        
        movieTitleLabel.text = movieRepresentation.title
    }
}
