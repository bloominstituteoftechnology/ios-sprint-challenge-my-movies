//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Madison Waters on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchTableViewCellDelegate: class {
    func saveMovieToList(cell: MovieSearchTableViewCell)
}

class MovieSearchTableViewCell: UITableViewCell {

    var delegate: MovieSearchTableViewCellDelegate!
    
    @IBOutlet weak var MovieTitleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        delegate?.saveMovieToList(cell: self)
    }
    
    
    func updateView() {
        if let movieRepresentation = movieRepresentation {
            MovieTitleLabel.text = movieRepresentation.title
        }
    }
    
    var movieRepresentation: MovieRepresentation? {
        didSet { updateView() }
    }
    
    var movieController = MovieController()
}
