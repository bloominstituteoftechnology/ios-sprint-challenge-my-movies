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
    var movieController: MovieController?
    var movieRepresentation: MovieRepresentation? {
        didSet { updateView() }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var movieSearchLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        movieSearchCellDelegate?.addMovieTapped(on: self)
    }
    
    func updateView() {
        guard let title = movieRepresentation?.title else { return }
        
        movieSearchLabel.text = title
        
    }
}
