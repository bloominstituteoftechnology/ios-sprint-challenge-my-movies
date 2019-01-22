//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Madison Waters on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchTableViewCellDelegate: class {
    func saveMovieToList(movie: MovieRepresentation)
}

class MovieSearchTableViewCell: UITableViewCell {

    weak var delegate: MovieSearchTableViewCellDelegate!
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateView()
        }
    }
    
    @IBOutlet weak var MovieTitleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        guard let movieRepresentation = movieRepresentation else { return }
        delegate?.saveMovieToList(movie: movieRepresentation)
        addMovieButton.setTitle("Added", for: .normal)
    }
    
    
    func updateView() {
        guard let movieRepresentation = movieRepresentation else { return }
        MovieTitleLabel.text = movieRepresentation.title
        
    }
}
