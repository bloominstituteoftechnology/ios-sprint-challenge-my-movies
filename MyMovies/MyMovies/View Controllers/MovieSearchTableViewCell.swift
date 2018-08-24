//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Lisa Sampson on 8/24/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchTableViewCellDelegate: class {
    func addMovieButtonWasTapped(on cell: MovieSearchTableViewCell)
}

class MovieSearchTableViewCell: UITableViewCell {
    
    @IBAction func addButtonTapped(_ sender: Any) {
        delegate?.addMovieButtonWasTapped(on: self)
    }
    
    func updateViews() {
        guard let movie = movieRep else { return }
        
        titleLabel.text = movie.title
    }
    
    var movieRep: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    weak var delegate: MovieSearchTableViewCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
}
