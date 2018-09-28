//
//  MovieDetailTableViewCell.swift
//  MyMovies
//
//  Created by Iyin Raphael on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MovieDetailTableViewCellDelegate: class {
    func addMovie(movieRepresentation: MovieRepresentation)
}

class MovieDetailTableViewCell: UITableViewCell {

    private func updateViews() {
        guard let movieRepresentation = movieRepresentation else { return }
        
        titleLabel.text = movieRepresentation.title
    }
    
    weak var delegate: MovieDetailTableViewCellDelegate?
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    @IBAction func addMovie(_ sender: Any) {
        guard let movieRepresentation = movieRepresentation else { return }
        delegate?.addMovie(movieRepresentation: movieRepresentation)
        addMovieButton.setTitle("Added", for: .normal)
        
    }
}
