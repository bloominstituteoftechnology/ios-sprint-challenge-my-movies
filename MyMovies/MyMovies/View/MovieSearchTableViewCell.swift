//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Ilgar Ilyasov on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchTableViewCellDelegate: class {
    func addMovieTapped(for movieRepresentation: MovieRepresentation)
}

class MovieSearchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var movieSearchCellDelegate: MovieSearchTableViewCellDelegate?
    var movieRepresentation: MovieRepresentation? {
        didSet { updateView() }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var movieSearchLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        guard let movieRepresentation = movieRepresentation else { return }
        movieSearchCellDelegate?.addMovieTapped(for: movieRepresentation)
        addMovieButton.setTitle("added", for: .normal)
    }
    
    func updateView() {
        if let movieRepresentation = movieRepresentation {
            movieSearchLabel.text = movieRepresentation.title
        }
    }
}
