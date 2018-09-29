//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Ilgar Ilyasov on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchTableViewCellDelegate: class {
    func addMovieTapped(on cell: MovieSearchTableViewCell)
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
        addMovieButton.setTitle("Added", for: .normal)
        movieSearchCellDelegate?.addMovieTapped(on: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        addMovieButton.setTitle("Add movie", for: .normal)
    }
    
    func updateView() {
        if let movieRepresentation = movieRepresentation {
            movieSearchLabel.text = movieRepresentation.title
        }
    }
}
