//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Sean Acres on 7/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchTableViewCellDelegate: class {
    func addMovieTapped(on cell: MovieSearchTableViewCell)
}

class MovieSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    weak var delegate: MovieSearchTableViewCellDelegate?
    
    @IBAction func addMovieTapped(_ sender: Any) {
        self.delegate?.addMovieTapped(on: self)
    }
    
    func updateViews() {
        titleLabel.text = movie?.title
        addMovieButton.isUserInteractionEnabled = true
        addMovieButton.setTitle("Add Movie", for: .normal)
    }
}
